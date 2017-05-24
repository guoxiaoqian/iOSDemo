//
//  StatePattern_Light.h
//  Demo
//
//  Created by 郭晓倩 on 2017/5/24.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LightState.h"

@interface StatePattern_Light : NSObject

@property (strong,nonatomic) LightState* state;

- (instancetype)initWithState:(LightState*)state;

- (void)pressSwitch;

@end
