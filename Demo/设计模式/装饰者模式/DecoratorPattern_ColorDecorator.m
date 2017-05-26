//
//  DecoratorPattern_ColorDecorator.m
//  Demo
//
//  Created by 郭晓倩 on 2017/5/26.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "DecoratorPattern_ColorDecorator.h"

@implementation DecoratorPattern_ColorDecorator

-(void)lightOn{
    [self.light lightOn];
    NSLog(@"发出了美丽的颜色");
}

@end
