//
//  LightState.h
//  Demo
//
//  Created by 郭晓倩 on 2017/5/24.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StatePattern_Light;
@interface LightState : NSObject

-(void)pressSwitch:(StatePattern_Light*)light;

@end
