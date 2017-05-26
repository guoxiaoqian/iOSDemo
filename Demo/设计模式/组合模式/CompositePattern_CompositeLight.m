//
//  CompositePattern_CompositeLight.m
//  Demo
//
//  Created by 郭晓倩 on 2017/5/26.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "CompositePattern_CompositeLight.h"

@interface CompositePattern_CompositeLight ()

@property (strong,nonatomic) NSMutableArray<CompositePattern_AbstractLight*>* childLights;

@end

@implementation CompositePattern_CompositeLight

-(instancetype)initWithLights:(NSArray<CompositePattern_AbstractLight*>*)lights{
    if (self = [super init]) {
        self.childLights = [NSMutableArray new];
        [self.childLights addObjectsFromArray:lights];
    }
    return self;
}

-(void)lightOn{
    for (CompositePattern_AbstractLight* light in self.childLights) {
        [light lightOn];
    }
}

@end
