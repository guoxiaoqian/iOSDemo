//
//  DecoratorPattern_AbstractDecorator.h
//  Demo
//
//  Created by 郭晓倩 on 2017/5/26.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "DecoratorPattern_AbstractLight.h"

@interface DecoratorPattern_AbstractDecorator : DecoratorPattern_AbstractLight

@property (strong,nonatomic) DecoratorPattern_AbstractLight* light;

-(instancetype)initWithLight:(DecoratorPattern_AbstractLight*)light;

@end
