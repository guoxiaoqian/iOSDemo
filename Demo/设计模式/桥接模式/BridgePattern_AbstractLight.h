//
//  BridgePattern_AbstractLight.h
//  Demo
//
//  Created by 郭晓倩 on 2017/5/26.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BridgePattern_AbstractColor.h"

@interface BridgePattern_AbstractLight : NSObject

-(NSString*)getSizeDescripiton;

-(void)showColor:(BridgePattern_AbstractColor*)color;

@end
