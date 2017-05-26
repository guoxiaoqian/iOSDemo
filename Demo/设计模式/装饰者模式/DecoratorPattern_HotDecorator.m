//
//  DecoratorPattern_HotDecorator.m
//  Demo
//
//  Created by 郭晓倩 on 2017/5/26.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "DecoratorPattern_HotDecorator.h"

@implementation DecoratorPattern_HotDecorator

-(void)lightOn{
    [self.light lightOn];
    NSLog(@"放出了大量的热");
}

@end
