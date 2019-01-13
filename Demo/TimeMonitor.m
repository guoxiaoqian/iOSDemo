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
    g_monitorDic[name] = @(CFAbsoluteTimeGetCurrent());
}

+ (void)endMonitor:(NSString*)name {
    NSNumber* beginTime = g_monitorDic[name];
    CFAbsoluteTime diff = CFAbsoluteTimeGetCurrent() - beginTime.doubleValue;
    NSLog(@"Event %@ spend %fs",name,diff);
}

@end
