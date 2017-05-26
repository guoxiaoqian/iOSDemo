//
//  DecoratorPattern_AbstractDecorator.m
//  Demo
//
//  Created by 郭晓倩 on 2017/5/26.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "DecoratorPattern_AbstractDecorator.h"

@implementation DecoratorPattern_AbstractDecorator

-(instancetype)initWithLight:(DecoratorPattern_AbstractLight*)light{
    if (self = [super init]) {
        self.light = light;
    }
    return self;
}

-(void)lightOn{
    ASSERT_NOT_IMPLEMENTED;
}

@end
