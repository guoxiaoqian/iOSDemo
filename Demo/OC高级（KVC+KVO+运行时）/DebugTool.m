//
//  DebugTool.m
//  Demo
//
//  Created by 郭晓倩 on 2017/8/10.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "DebugTool.h"

@implementation DebugTool

+ (void)testDebugTool{
    [self testAddressSanitizer];
}

+ (void)testAddressSanitizer{
    __unsafe_unretained NSObject* obj = nil;
    
    {
        obj = [[NSObject alloc] init];
    }
    
    
    NSLog(@"%@",obj);
}

@end
