//
//  RunloopVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/5/10.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "RunloopVC.h"
#import <Foundation/NSPort.h>

@interface RunloopVC () <NSPortDelegate,NSMachPortDelegate>

@property NSThread* workerThread;
@property CFRunLoopSourceRef workerSource;
@property NSRunLoop* workerRunloop;
@property dispatch_source_t timer;
@property CFRunLoopObserverRef observerForMainRunloop;
@property CFRunLoopObserverRef observerForWorkerRunloop;

@end

@implementation RunloopVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initMainThread];
    
    [self initWorkerThread];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"主线程唤醒工作线程");
        [self fireSource0:self.workerRunloop source:self.workerSource];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self removeSource0:self.workerRunloop source:self.workerSource];
    [self removeObserver:self.workerRunloop observer:self.observerForWorkerRunloop];
    CFRunLoopStop([self.workerRunloop getCFRunLoop]);
    [self.workerThread cancel];
    
    [self removeObserver:[NSRunLoop mainRunLoop] observer:self.observerForMainRunloop];
}

#pragma mark - 主线程

-(void)initMainThread{
    [[NSThread currentThread] setName:@"mainThread"];
    
    self.observerForMainRunloop = [self addObserver:[NSRunLoop mainRunLoop]];
    [self addSelector:[NSRunLoop mainRunLoop]];
    [self addBlock:[NSRunLoop mainRunLoop]];
    [self dispatchSource:[NSRunLoop mainRunLoop]];
}

#pragma mark - 工作线程

-(void)initWorkerThread{
    self.workerThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadEntry) object:nil];
    [self.workerThread start];
}

-(void)threadEntry{
    @autoreleasepool {
        [[NSThread currentThread] setName:@"workerThread"];
        NSRunLoop* runloop = [NSRunLoop currentRunLoop];
        
        //RunLoop 启动前内部必须要有至少一个 Timer/Observer/Source,否则直接结束
        //通常情况下，调用者需要持有这个 NSMachPort (mach_port) 并在外部线程通过这个 port 发送消息到 loop 内；但此处添加 port 只是为了让 RunLoop 不至于退出，并没有用于实际的发送消息。
        [runloop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        
        self.observerForWorkerRunloop = [self addObserver:runloop];
        [self addTimer:runloop];
        [self addDisplayLink:runloop];
        
        self.workerSource = [self addSource0:runloop];
        self.workerRunloop = runloop;
        
        [runloop run];
    };
}

#pragma mark - Runloop Observer

-(CFRunLoopObserverRef)addObserver:(NSRunLoop*)runloop{
    //1.创建监听者
    /*
     第一个参数:怎么分配存储空间
     第二个参数:要监听的状态 kCFRunLoopAllActivities 所有的状态
     第三个参数:时候持续监听
     第四个参数:优先级 总是传0
     第五个参数:当状态改变时候的回调
     */
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        
        NSString* statusStr = nil;
        switch (activity) {
            case kCFRunLoopEntry:
                statusStr = @"即将进入runloop";
                break;
            case kCFRunLoopBeforeTimers:
                statusStr = @"即将处理timer事件";
                break;
            case kCFRunLoopBeforeSources:
                statusStr = @"即将处理source事件";
                break;
            case kCFRunLoopBeforeWaiting:
                statusStr = @"即将进入睡眠";
                break;
            case kCFRunLoopAfterWaiting:
                statusStr = @"被唤醒";
                break;
            case kCFRunLoopExit:
                statusStr = @"runloop退出";
                break;
                
            default:
                break;
        }
        
        NSLog(@"%@%@",[NSThread currentThread].name,statusStr);
    });
    
    /*
     第一个参数:要监听哪个runloop
     第二个参数:观察者
     第三个参数:运行模式
     */
    CFRunLoopAddObserver([runloop getCFRunLoop],observer, kCFRunLoopDefaultMode);
    return observer;
}

-(void)removeObserver:(NSRunLoop*)runloop observer:(CFRunLoopObserverRef)observer{
    CFRunLoopRemoveObserver([runloop getCFRunLoop], observer, kCFRunLoopDefaultMode);
    CFRelease(observer);
}

#pragma mark - 自定义输入源（Source0）

//注：1，输入源就是一类事件（命令）处理机制。他是线程间的事件（命令）异步通讯机制，所以不能试图通过这个机制实现进程间的通讯。


//＝＝＝当将输入源附加到run loop时，调用这个协调调度例程，将源注册到客户端（可以理解为其他线程）
//当source添加进runloop的时候，调用此回调方法 <== CFRunLoopAddSource(runLoop, source, mode);
void RunLoopSourceScheduleRoutine (void *info, CFRunLoopRef rl, CFStringRef mode)
{
    LOG_FUNCTION;
}
//＝＝＝在输入源被告知（signal source）时，调用这个处理例程，这儿只是简单的调用了 [obj sourceFired]方法
//当sourcer接收到消息的时候，调用此回调方法(CFRunLoopSourceSignal(source);CFRunLoopWakeUp(runLoop);
void RunLoopSourcePerformRoutine (void *info)
{
    NSLog(@"事件源开始处理...");//SOURCE0
    sleep(1);
    NSLog(@"事件源处理结束");
}
//＝＝＝如果使用CFRunLoopSourceInvalidate/CFRunLoopRemoveSource函数把输入源从run loop里面移除的话，系统会调用这个取消例程，并且把输入源从注册的客户端（可以理解为其他线程）里面移除
//当source 从runloop里删除的时候，调用此回调方法 <== CFRunLoopRemoveSource(runLoop, source, mode);
void RunLoopSourceCancelRoutine (void *info, CFRunLoopRef rl, CFStringRef mode)
{
    LOG_FUNCTION;
}

//非基于端口port，也就是触摸，滚动，selector选择器事件
-(CFRunLoopSourceRef)addSource0:(NSRunLoop*)runloop{
    
    /*
     context.version = 0;
     context.info = self;
     context.retain = NULL;
     context.release = NULL;
     context.copyDescription = CFCopyDescription;
     context.equal = CFEqual;
     context.hash = CFHash;
     context.schedule = RunLoopSourceScheduleRoutine;
     context.cancel = RunLoopSourceCancelRoutine;
     context.perform = RunLoopSourcePerformRoutine;
     */
    CFRunLoopSourceContext context = {0, (__bridge void *)(self), NULL, NULL, NULL, NULL, NULL,
        &RunLoopSourceScheduleRoutine,
        &RunLoopSourceCancelRoutine,
        &RunLoopSourcePerformRoutine};
    
    CFRunLoopSourceRef runLoopSource = CFRunLoopSourceCreate(NULL, 0, &context);
    
    CFRunLoopAddSource([runloop getCFRunLoop], runLoopSource, kCFRunLoopDefaultMode);
    
    return runLoopSource;
}

-(void)fireSource0:(NSRunLoop*)runloop source:(CFRunLoopSourceRef)source{
    CFRunLoopSourceSignal(source);
    CFRunLoopWakeUp([runloop getCFRunLoop]);
}

-(void)removeSource0:(NSRunLoop*)runloop source:(CFRunLoopSourceRef)source{
    CFRunLoopRemoveSource([runloop getCFRunLoop], source, kCFRunLoopDefaultMode);
    CFRelease(source);
}

#pragma mark - 配置基于端口的输入源（source1）

-(void)addSource1:(NSRunLoop*)runloop{
    
}


#pragma mark - 配置定时源

void RunLoopTimerCallBack(CFRunLoopTimerRef timer, void *info){
    LOG_FUNCTION;//TIMER
}

-(void)addTimer:(NSRunLoop*)runloop{
    CFRunLoopTimerContext context = {0, NULL, NULL, NULL, NULL};
    CFRunLoopTimerRef timer = CFRunLoopTimerCreate(kCFAllocatorDefault, 0.1, 1, 0, 0, &RunLoopTimerCallBack, &context);
    
    CFRunLoopAddTimer([runloop getCFRunLoop], timer, kCFRunLoopCommonModes);
    
    
    //NSTimer与CFRunloopTimerRef可以桥接转换
//    NSTimer* timer2 = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"timer2");
//    }];
//    [runloop addTimer:timer2 forMode:NSRunLoopCommonModes];
}

-(void)addDisplayLink:(NSRunLoop*)runloop{
    CADisplayLink* link = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCome)];
    [link addToRunLoop:runloop forMode:NSRunLoopCommonModes];
}

-(void)displayLinkCome{
    LOG_FUNCTION; //SOURCE1
    //也会阻塞事件处理
    sleep(1);
}

#pragma mark - 其他源

//RunLoop主要处理以下6类事件：
//static void __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__();
//static void __CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__();
//static void __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__();
//static void __CFRUNLOOP_IS_CALLING_OUT_TO_A_TIMER_CALLBACK_FUNCTION__();
//static void __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__();
//static void __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__();

//他对这六类事件有如下解释
//1.Observer事件，runloop中状态变化时进行通知。（微信卡顿监控就是利用这个事件通知来记录下最近一次main runloop活动时间，在另一个check线程中用定时器检测当前时间距离最后一次活动时间过久来判断在主线程中的处理逻辑耗时和卡主线程）。这里还需要特别注意，CAAnimation是由RunloopObserver触发回调来重绘，接下来会讲到。
//
//2.Block事件，非延迟的NSObject PerformSelector立即调用，runloop的performBlock,CFRunLoopPerformBlock。
//
//3.Main_Dispatch_Queue事件：GCD中dispatch到main queue的block会被dispatch到main loop执行，dispatch_after。
//
//4.Timer事件：延迟的NSObject PerformSelector，timer事件。
//
//5.Source0事件：处理如UIEvent，CFSocket这类事件。需要手动触发。触摸事件其实是Source1接收系统事件后在回调 __IOHIDEventSystemClientQueueCallback() 内触发的 Source0，Source0 再触发的 _UIApplicationHandleEventQueue()。source0一定是要唤醒runloop及时响应并执行的，如果runloop此时在休眠等待系统的 mach_msg事件，那么就会通过source1来唤醒runloop执行。

//
//6.Source1事件：处理系统内核的mach_msg事件。（CADisplayLink也是这里触发）。


-(void)addSelector:(NSRunLoop*)runloop{
    //OBSERVER
    [runloop performSelector:@selector(selectorCome) target:self argument:nil order:0 modes:@[NSRunLoopCommonModes]];

    //TIMER
    [self performSelector:@selector(selectorCome2) withObject:nil afterDelay:1 inModes:@[NSRunLoopCommonModes]];
    
}

-(void)selectorCome{
    NSLog(@"selectorCome");
}

-(void)selectorCome2{
    NSLog(@"selectorCome2");
}

-(void)addBlock:(NSRunLoop*)runloop{
    
    CFRunLoopPerformBlock([runloop getCFRunLoop],kCFRunLoopDefaultMode,^{
        //BLOCK
        NSLog(@"blockCome");
    });
    
    [runloop performInModes:@[NSRunLoopCommonModes] block:^{
        //IOS 10后支持
        //BLOCK
        NSLog(@"blockCome1");
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //DISPATCH
        NSLog(@"blockCome2");
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //DISPATCH
        NSLog(@"blockCome3");
    });
}

-(void)dispatchSource:(NSRunLoop*)runloop{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        //DISPATCH——SOURCE_INVOKE
        NSLog(@"sourceTimerCome");
        dispatch_suspend(timer);
        dispatch_cancel(timer);
    });
    dispatch_resume(timer);
    self.timer = timer; //一定要持有，否则timer被释放
}


@end
