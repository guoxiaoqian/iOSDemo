//
//  LightState_Off.m
//  Demo
//
//  Created by 郭晓倩 on 2017/5/24.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "LightState_On.h"
#import "LightState_Off.h"
#import "StatePattern_Light.h"

@implementation LightState_Off

-(void)pressSwitch:(StatePattern_Light*)light{
    NSLog(@"当前状态为关闭，切换到开启状态");
    light.state = [LightState_On new];
}

@end
