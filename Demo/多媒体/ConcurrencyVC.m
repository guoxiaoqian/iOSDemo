//
//  ConcurrencyVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/4/2.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "ConcurrencyVC.h"

#pragma mark - 自定义Operation

typedef enum : NSUInteger {
    MyOperationStateReady,
    MyOperationStateExecuting,
    MyOperationStateFinished,
} MyOperationState;

@interface MyOperation : NSOperation

@property (assign,nonatomic) int maxCount;
@property (assign,nonatomic) MyOperationState state;

@end

@implementation MyOperation

-(instancetype)initWithMaxCount:(int)maxCount{
    if (self = [super init]) {
        self.maxCount = maxCount;
        self.state = MyOperationStateReady;
    }
    return self;
}

-(void)start{
    if ([self isCancelled] || self.isFinished) {
        self.state = MyOperationStateFinished;
        return;
    }
    //异步执行
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    self.state = MyOperationStateExecuting;
}

-(void)main{
    int i = 1;
    while (!self.isCancelled && !self.isFinished) {
        sleep(1);
        NSLog(@"operation name %@ count %d",self.name,i);
        if (i >= self.maxCount) {
            self.state = MyOperationStateFinished;
        }
        i++;
    }
    if(self.isCancelled){
        self.state = MyOperationStateFinished;
    }
}

//The NSOperation class is key-value observing (KVO) compliant for the following key paths:
//isCancelled
//isConcurrent
//isExecuting
//isFinished
//isReady
//dependencies
//queuePriority
//completionBlock

-(BOOL)isReady{
    return  self.state == MyOperationStateReady;
}

-(BOOL)isFinished{
    return  self.state == MyOperationStateFinished;
}

-(BOOL)isExecuting{
    return self.state == MyOperationStateExecuting;
}

-(BOOL)isConcurrent{
    return YES;
}

-(void)setState:(MyOperationState)state{
    NSString* oldKeyPath = [self keyPathForState:self.state];
    NSString* newKeyPath = [self keyPathForState:state];
    
    [self willChangeValueForKey:oldKeyPath];
    [self willChangeValueForKey:newKeyPath];
    
    _state = state;
    
    [self didChangeValueForKey:oldKeyPath];
    [self didChangeValueForKey:newKeyPath];
}

-(NSString*)keyPathForState:(MyOperationState)state{
    switch (state) {
        case MyOperationStateReady:
            return @"isReady";
        case MyOperationStateFinished:
            return @"isFinished";
        case MyOperationStateExecuting:
            return @"isExecuting";
        default:
            return @"state";
    }
}

@end

#pragma mark - ConcurrencyVC

@interface ConcurrencyVC ()

@property (strong,nonatomic) NSOperationQueue* operationQueue;

@end

@implementation ConcurrencyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self operationQueueGenaral];
    
    [self operationQueueCustom];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Operation Queue (依赖，优先级，取消，状态KVO)

-(void)operationQueueGenaral{
    NSOperationQueue* queue = [[NSOperationQueue alloc] init]; //默认创建的是非主线程顺序队列
    //    queue.underlyingQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);//IOS8可以指定底层队列类型
    //    [queue setMaxConcurrentOperationCount:2];
    
    
    NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"block 开始 current Thread %@",[NSThread currentThread]);
    }];
    [operation addExecutionBlock:^{ //追加的block跟前面的block不是顺序关系，可能先执行
        NSLog(@"block 补充");
    }];
    operation.name = @"operation1";
    [operation setCompletionBlock:^{
        NSLog(@"block 结束");
    }];
    
    NSString* data = @"郭晓倩太帅";
    NSOperation* operatin2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(operationInvoke:) object:data];
    
    //添加依赖
    [operation addDependency:operatin2];
    
    //设置优先级（状态都为ready时，优先级高的会先执行；所依赖的operation都完成时自动设置ready）
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    
    //添加队列
    [queue addOperation:operation];
    [queue addOperation:operatin2];
    
    //队列管理
    //    [queue setSuspended:YES];//挂起队列
    //    [queue setSuspended:NO];
    //    [queue waitUntilAllOperationsAreFinished];
    //    [queue cancelAllOperations];
}

- (void)operationQueueCustom{
    MyOperation* operation1 = [[MyOperation alloc] initWithMaxCount:5];
    operation1.name = @"operation1";
    MyOperation* operation2 = [[MyOperation alloc] initWithMaxCount:5];
    operation2.name = @"operation2";
    NSOperationQueue* queue = [NSOperationQueue mainQueue];
    
    [queue addOperation:operation1];
    [queue addOperation:operation2];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [operation1 cancel];
    });
}

-(void)operationInvoke:(id)object{
    NSLog(@"invoke %@",object);
}

#pragma mark - Dispatch Queue

#pragma mark - Dispatch Source

#pragma mark - Thread

@end
