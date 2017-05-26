//
//  BridgePattern_AbstractLight.m
//  Demo
//
//  Created by 郭晓倩 on 2017/5/26.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "BridgePattern_AbstractLight.h"

@implementation BridgePattern_AbstractLight

-(NSString*)getSizeDescripiton{
    ASSERT_NOT_IMPLEMENTED;
    return @"";
}

-(void)showColor:(BridgePattern_AbstractColor*)color{
    NSLog(@"%@发出了%@的光",[self getSizeDescripiton],[color getColorDescription]);
}

@end
