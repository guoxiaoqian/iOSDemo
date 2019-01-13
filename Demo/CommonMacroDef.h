//
//  commonMacroDef.h
//  Demo
//
//  Created by 郭晓倩 on 17/3/9.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#ifndef commonMacroDef_h
#define commonMacroDef_h

#import "TimeMonitor.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define LOG_FUNCTION NSLog(@"%s",__FUNCTION__)
#define ASSERT_NOT_IMPLEMENTED NSAssert(NO, @"not implemented")

//检查系统版本
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


#define  TIME_MONITOR_BEIGIN(_name_) [TimeMonitor beginMonitor:_name_];
#define  TIME_MONITOR_END(_name_) [TimeMonitor endMonitor:_name_];

#endif /* commonMacroDef_h */
