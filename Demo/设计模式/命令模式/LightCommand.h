//
//  LightCommand.h
//  Demo
//
//  Created by 郭晓倩 on 2017/5/24.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandPattern_Light.h"

@interface LightCommand : NSObject

@property (strong,nonatomic) CommandPattern_Light* light;

-(instancetype)initWithLight:(CommandPattern_Light*)light;

-(void)execute;

@end
