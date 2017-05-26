//
//  CompositePattern_CompositeLight.h
//  Demo
//
//  Created by 郭晓倩 on 2017/5/26.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "CompositePattern_AbstractLight.h"

@interface CompositePattern_CompositeLight : CompositePattern_AbstractLight

-(instancetype)initWithLights:(NSArray<CompositePattern_AbstractLight*>*)lights;

@end
