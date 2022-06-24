//
//  TimeMonitor.m
//  Demo
//
//  Created by 郭晓倩 on 2019/1/13.
//  Copyright © 2019 郭晓倩. All rights reserved.
//

#import "TimeMonitor.h"

static NSMutableDictionary* g_monitorDic = nil;

@implementation TimeMonitor

+ (void)beginMonitor:(NSString*)name {
    if (g_monitorDic == nil) {
        g_monitorDic = [NSMutableDictionary new];
    }
    g_monitorDic[name] = @(CACurrentMediaTime());
}

+ (void)endMonitor:(NSString*)name {
    NSNumber* beginTime = g_monitorDic[name];
    CFTimeInterval diff = CACurrentMediaTime() - beginTime.doubleValue;
    NSLog(@"[TimeMonitor] Event %@ spend %.2fs",name,diff);
}

@end
