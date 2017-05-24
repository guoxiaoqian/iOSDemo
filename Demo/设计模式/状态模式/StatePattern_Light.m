//
//  StatePattern_Light.m
//  Demo
//
//  Created by 郭晓倩 on 2017/5/24.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "StatePattern_Light.h"
#import "LightState.h"

@interface StatePattern_Light ()


@end

@implementation StatePattern_Light

- (instancetype)initWithState:(LightState*)state{
    if (self = [super init]) {
        self.state = state;
    }
    return self;
}

- (void)pressSwitch{
    [self.state pressSwitch:self];
}

@end
