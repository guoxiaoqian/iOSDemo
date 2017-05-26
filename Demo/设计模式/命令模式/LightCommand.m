//
//  LightCommand.m
//  Demo
//
//  Created by 郭晓倩 on 2017/5/24.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "LightCommand.h"

@interface LightCommand ()


@end

@implementation LightCommand

-(instancetype)initWithLight:(CommandPattern_Light *)light{
    if (self = [super init]) {
        self.light = light;
    }
    return self;
}

-(void)execute{
    ASSERT_NOT_IMPLEMENTED;
}

@end
