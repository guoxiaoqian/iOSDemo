//
//  TimeVC.m
//  Demo
//
//  Created by 郭晓倩 on 2022/6/7.
//  Copyright © 2022 郭晓倩. All rights reserved.
//

#import "TimeVC.h"

#import <QuartzCore/CABase.h>

@interface TimeVC ()

@property  CFTimeInterval beginTime;
@property  CFTimeInterval backgoundTime;

@end

@implementation TimeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = [@[
        [ClickModel modelWithSelector:@selector(testCFTimeIntervalBegin)],
        [ClickModel modelWithSelector:@selector(testCFTimeIntervalEnd)],
    ] mutableCopy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAppEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willAppEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)testCFTimeIntervalBegin {
    self.beginTime = CACurrentMediaTime();
    NSLog(@"beginTime: %.2f",self.beginTime);
}

- (void)testCFTimeIntervalEnd {
    CFTimeInterval endTime = CACurrentMediaTime();
    NSLog(@"endTime: %.2f diff:%.2fs",endTime,endTime-self.beginTime);
}

- (void)didAppEnterBackground {
    self.backgoundTime = CACurrentMediaTime();
    NSLog(@"backgroundTime: %.2f",self.backgoundTime);

}

- (void)willAppEnterForeground {
    CFTimeInterval endTime = CACurrentMediaTime();
    NSLog(@"foregroundTime: %.2f diff:%.2f",endTime, endTime - self.backgoundTime);

}

@end
