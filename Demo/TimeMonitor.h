//
//  TimeMonitor.h
//  Demo
//
//  Created by 郭晓倩 on 2019/1/13.
//  Copyright © 2019 郭晓倩. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeMonitor : NSObject

+ (void)beginMonitor:(NSString*)name;
+ (void)endMonitor:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
