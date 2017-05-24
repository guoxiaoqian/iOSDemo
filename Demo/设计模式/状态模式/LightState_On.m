//
//  LightState_On.m
//  Demo
//
//  Created by 郭晓倩 on 2017/5/24.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "LightState_On.h"
#import "LightState_Off.h"
#import "StatePattern_Light.h"

@implementation LightState_On

-(void)pressSwitch:(StatePattern_Light*)light{
    NSLog(@"当前状态为开启，切换到关闭状态");
    light.state = [LightState_Off new];
}

@end
