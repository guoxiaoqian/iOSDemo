//
//  ConcurrencyVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/4/2.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "ConcurrencyVC.h"

#pragma mark - 自定义Thread

@interface MyThread : NSThread

@end

@implementation MyThread

-(void)main{
    //最外层一定是自动释放池
    @autoreleasepool {
        
        //子线程中创建定时器
        __block int count = 0;
        NSTimer* timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            if ([self isCancelled]) {
                [timer invalidate];
                timer = nil;
                NSLog(@"MyThread timer canceld");
            }else{
                NSLog(@"MyThread timer %d",count);
            }
            count ++;
        }];
        
        //        在Cocoa中，每个线程(NSThread)对象中内部都有一个run loop（NSRunLoop）对象用来循环处理输入事件(子线程默认是没创建的只有去获取Runloop的时候才创建)。
        
        //首次获取，会为子线程创建Runloop并关联
        NSRunLoop* runloop = [NSRunLoop currentRunLoop];
        [runloop addTimer:timer forMode:NSRunLoopCommonModes];
        
        //执行runloop
        //        [runloop run];
        [runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
        
        //用runloop就不用循环了
        //        int i = 0;
        //        while (![self isCancelled] && i < 100) {
        //            [NSThread sleepForTimeInterval:1];
        //            NSLog(@"MyThread run %d",i);
        //            i++;
        //        }
    }
}

@end

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

//封装异步操作时，必须返回YES
-(BOOL)isConcurrent{
    return YES;
}

//封装异步操作时，必须返回YES,这个NSOperation执行完毕后不会自动变为finished状态，需要手动设置
-(BOOL)isAsynchronous{
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
    //
    //    [self operationQueueGenaral];
    //
    //    [self operationQueueCustom];
    //
//    [self dispatchQueueGeneral];
    
    //    [self thread];
    
    [self testPerformSelector];
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
        NSLog(@"operation block 开始 current Thread %@",[NSThread currentThread]);
    }];
    [operation addExecutionBlock:^{ //追加的block跟前面的block不是顺序关系，可能先执行
        NSLog(@"operation block 补充");
    }];
    operation.name = @"operation1";
    [operation setCompletionBlock:^{
        NSLog(@"operation block 结束");
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
    NSLog(@"operation invoke %@",object);
}

#pragma mark - Dispatch Queue

-(void)dispatchQueueGeneral{
    //获取系统提供的队列(四个不同优先级并行队列，一个主队列)
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    //创建新队列(文档中说要释放,结果ARC中禁用？？？)
    dispatch_queue_t cocurrentQueue = dispatch_queue_create("concurrent queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t serialQueue = dispatch_queue_create("serial queue", DISPATCH_QUEUE_SERIAL);
    //label可以为NULL，没有索引关系。 即可创建多个相同label的队列。
    dispatch_queue_t serialQueue2 = dispatch_queue_create("serial queue", DISPATCH_QUEUE_SERIAL);
    NSLog(@"create queue1:%p  queue2:%p",serialQueue,serialQueue2);

    
    //分发任务(同步和异步)
    dispatch_async(globalQueue, ^{
        NSLog(@"dispatch_async 1 开始");
        sleep(2);
        NSLog(@"dispatch_async 1 结束");
    });
    dispatch_async(globalQueue, ^{
        NSLog(@"dispatch_async 2 开始");  //任务2可能先执行
        sleep(1);
        NSLog(@"dispatch_async 2 结束");
    });
    
    //其他应用--加快循环(并发队列)
    dispatch_apply(10, globalQueue, ^(size_t i) {
        NSLog(@"dispatch_apply %d",(int)i);
    });
    
    //其他应用--延迟(队列自带Runloop)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), globalQueue, ^{
        NSLog(@"dispatch_after globalQueue");
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), cocurrentQueue, ^{
        NSLog(@"dispatch_after cocurrentQueue");
    });
    
    //其他应用--单例
    static dispatch_once_t onceToken;
    dispatch_async(globalQueue, ^{
        dispatch_once(&onceToken, ^{
            NSLog(@"dispatch_once 1");
        });
    });
    dispatch_async(globalQueue, ^{
        dispatch_once(&onceToken, ^{
            NSLog(@"dispatch_once 2");
        });
    });
    
    //其他应用--暂停/恢复
    dispatch_suspend(globalQueue);
    dispatch_resume(globalQueue);
    
    //其他应用--信号量（有限资源访问），也可用来将异步变为同步(资源数改为1则退化为互斥锁,改为0则变为同步锁)
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    dispatch_async(serialQueue, ^{
        sleep(1);
        NSLog(@"dispatch_semaphore_t 解除等待");
        dispatch_semaphore_signal(sema);
    });
    NSLog(@"dispatch_semaphore_t 等待开始");
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    NSLog(@"dispatch_semaphore_t 等待结束");
    
    //其他应用--依赖，同步
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, globalQueue, ^{
        NSLog(@"dispatch_group_t 1");
    });
    dispatch_group_async(group, globalQueue, ^{
        NSLog(@"dispatch_group_t 2");
    });
    
    //Group串联依赖
    dispatch_group_t group2 = dispatch_group_create();
    dispatch_group_enter(group2); //手动管理Group计数，必须配套dispatch_group_leave，计数减为零则触发Notifiy;否则依赖该Group的block会直接执行
    dispatch_group_notify(group, globalQueue, ^{
        dispatch_async(globalQueue, ^{
            NSLog(@"dispatch_group_t 3");
            dispatch_group_leave(group2);
        });
    });
    dispatch_group_t group3 = dispatch_group_create();
    dispatch_group_enter(group3);
    
    //待任务组执行完毕时调用，不会阻塞当前线程
    dispatch_group_notify(group2, globalQueue, ^{
        dispatch_async(globalQueue, ^{
            NSLog(@"dispatch_group_t 4");
            dispatch_group_leave(group3);
        });
    });
    
    //Group等待
    //等待组任务完成，会阻塞当前线程，当任务组执行完毕时，才会解除阻塞当前线程；建议用dispatch_group_notify代替
    NSLog(@"dispatch_group_t 等待开始");
    dispatch_group_wait(group3, DISPATCH_TIME_FOREVER);
    NSLog(@"dispatch_group_t 等待结束");
    
    //Barrier串联依赖:????顺序不总是3在中间
    dispatch_async(cocurrentQueue, ^{
        NSLog(@"dispatch_barrier 1");
    });
    dispatch_async(cocurrentQueue, ^{
        NSLog(@"dispatch_barrier 2");
    });
    dispatch_barrier_async(cocurrentQueue, ^{
        NSLog(@"dispatch_barrier 3 barrier");
    });
    dispatch_async(cocurrentQueue, ^{
        NSLog(@"dispatch_barrier 4");
    });
    dispatch_async(cocurrentQueue, ^{
        NSLog(@"dispatch_barrier 5");
    });
    
}

//用顺序队列做同步操作比锁更高效
//This type of queue-based synchronization is more efficient than locks because locks always require an expensive kernel trap in both the contested and uncontested cases, whereas a dispatch queue works primarily in your application’s process space and only calls down to the kernel when absolutely necessary.

//Dispatch semaphores比一般信号量更高效
//A dispatch semaphore is similar to a traditional semaphore but is generally more efficient. Dispatch semaphores call down to the kernel only when the calling thread needs to be blocked because the semaphore is unavailable.

#pragma mark - Dispatch Source

//You can use dispatch sources to monitor events such as process notifications, signals, and descriptor events among others. When an event occurs, the dispatch source submits your task code asynchronously to the specified dispatch queue for processing.

-(void)dispatchSourceTimer{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"source timer event");
    });
    dispatch_resume(timer);
}

dispatch_source_t ProcessContentsOfFile(const char* filename)
{
    // Prepare the file for reading.
    int fd = open(filename, O_RDONLY);
    if (fd == -1)
        return NULL;
    fcntl(fd, F_SETFL, O_NONBLOCK);  // Avoid blocking the read operation
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t readSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,
                                                          fd, 0, queue);
    if (!readSource)
    {
        close(fd);
        return NULL;
    }
    
    // Install the event handler
    dispatch_source_set_event_handler(readSource, ^{
        size_t estimated = dispatch_source_get_data(readSource) + 1;
        // Read the data into a text buffer.
        char* buffer = (char*)malloc(estimated);
        if (buffer)
        {
            
            //            ssize_t actual = read(fd, buffer, (estimated));
            //            Boolean done = MyProcessFileData(buffer, actual);  // Process the data.
            //
            //            // Release the buffer when done.
            //            free(buffer);
            
            Boolean done = YES;
            
            // If there is no more data, cancel the source.
            if (done)
                dispatch_source_cancel(readSource);
        }
    });
    
    // Install the cancellation handler
    dispatch_source_set_cancel_handler(readSource, ^{close(fd);});
    
    // Start reading the file.
    dispatch_resume(readSource);
    return readSource;
}

dispatch_source_t WriteDataToFile(const char* filename)
{
    int fd = open(filename, O_WRONLY | O_CREAT | O_TRUNC,
                  (S_IRUSR | S_IWUSR | S_ISUID | S_ISGID));
    if (fd == -1)
        return NULL;
    fcntl(fd, F_SETFL); // Block during the write.
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t writeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE,
                                                           fd, 0, queue);
    if (!writeSource)
    {
        close(fd);
        return NULL;
    }
    
    dispatch_source_set_event_handler(writeSource, ^{
        //        size_t bufferSize = MyGetDataSize();
        //        void* buffer = malloc(bufferSize);
        //
        //        size_t actual = MyGetData(buffer, bufferSize);
        //        write(fd, buffer, actual);
        //
        //        free(buffer);
        
        // Cancel and release the dispatch source when done.
        dispatch_source_cancel(writeSource);
    });
    
    dispatch_source_set_cancel_handler(writeSource, ^{close(fd);});
    dispatch_resume(writeSource);
    return (writeSource);
}

dispatch_source_t MonitorNameChangesToFile(const char* filename)
{
    int fd = open(filename, O_EVTONLY);
    if (fd == -1)
        return NULL;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,
                                                      fd, DISPATCH_VNODE_RENAME, queue);
    if (source)
    {
        // Copy the filename for later use.
        //        int length = strlen(filename);
        //        char* newString = (char*)malloc(length + 1);
        //        newString = strcpy(newString, filename);
        //        dispatch_set_context(source, newString);
        //
        //        // Install the event handler to process the name change
        //        dispatch_source_set_event_handler(source, ^{
        //            const char*  oldFilename = (char*)dispatch_get_context(source);
        //            MyUpdateFileName(oldFilename, fd);
        //        });
        
        // Install a cancellation handler to free the descriptor
        // and the stored string.
        dispatch_source_set_cancel_handler(source, ^{
            char* fileStr = (char*)dispatch_get_context(source);
            free(fileStr);
            close(fd);
        });
        
        // Start processing events.
        dispatch_resume(source);
    }
    else
        close(fd);
    
    return source;
}

//Signal dispatch sources are not a replacement for the synchronous signal handlers you install using the sigaction function. Synchronous signal handlers can actually catch a signal and prevent it from terminating your application. Signal dispatch sources allow you to monitor only the arrival of the signal. In addition, you cannot use signal dispatch sources to retrieve all types of signals. Specifically, you cannot use them to monitor the SIGILL, SIGBUS, and SIGSEGV signals.




#pragma mark - Thread

-(void)thread{
    //常规创建
    NSThread* thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"NSThread %@ start",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:2];
        NSLog(@"NSThread %@ end",[NSThread currentThread]);
    }];
    [thread start];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [thread cancel];
    });
    
    //静态方法创建
    [NSThread detachNewThreadWithBlock:^{
        NSLog(@"NSThread %@ start",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:2];
        NSLog(@"NSThread %@ end",[NSThread currentThread]);
    }];
    
    
    //隐式创建线程
    [self performSelectorInBackground:@selector(doSomething) withObject:nil];
    
    
    //自定义线程
    MyThread* myThread = [[MyThread alloc] init];
    [myThread start];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [myThread cancel];
    });
}

-(void)doSomething{
    NSLog(@"NSThread %@ start",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:2];
    NSLog(@"NSThread %@ end",[NSThread currentThread]);
}

#pragma mark - PerformSelector

- (void)testPerformSelector {
    [self performSelector:@selector(delayToShowLoginUIWithType:) withObject:@(4) afterDelay:0.3];
    //object必须一样，才能取消掉
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayToShowLoginUIWithType:) object:nil];
}

- (void)delayToShowLoginUIWithType:(int)type {
    NSLog(@"delayToShowLoginUIWithType");
}

@end
