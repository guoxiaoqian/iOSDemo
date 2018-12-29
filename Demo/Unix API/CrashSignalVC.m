//
//  CrashSignalVC.m
//  Demo
//
//  Created by 郭晓倩 on 2018/12/29.
//  Copyright © 2018年 郭晓倩. All rights reserved.
//


static void signal_handler(int signal, siginfo_t *info, void *uap) {
    
}

#import "CrashSignalVC.h"

@interface CrashSignalVC ()

@end

@implementation CrashSignalVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)install {
    int fatalsigs[] = {SIGABRT, SIGBUS, SIGFPE, SIGILL, SIGSEGV, SIGTRAP};

    int nok = 0;
    for (int i=0; i<sizeof(fatalsigs)/sizeof(int); ++i)
    {
        struct sigaction sa = {0};
        sigemptyset(&sa.sa_mask);
        sa.sa_flags = SA_SIGINFO|SA_ONSTACK;
        sa.sa_sigaction = &signal_handler;
        nok += 0 == sigaction(fatalsigs[i], &sa, NULL);
    }
    return nok;
}

//我知道我可以使用backtrace()或[NSThread callStackSymbols]获取当前线程的堆栈跟踪,但是如何获得不同线程的堆栈跟踪(假设它已被冻结)？


@end
