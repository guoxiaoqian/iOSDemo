//
//  Singleton.m
//  Demo
//
//  Created by 郭晓倩 on 2017/8/12.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "Singleton.h"

@implementation Singleton

+(void)testSingleton{
    id s1 = [self sharedInstance];
    id s2 = [[self alloc] init];
    id s3 = [s2 copy];
    NSLog(@"Singleton shareInstance:%p alloc:%p copy:%p",s1,s2,s3);
}

+(instancetype)sharedInstance{
    static Singleton* singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
       singleton  = [super allocWithZone:NULL];
    });
    return singleton;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

-(instancetype)copy{
    return self;
}

-(instancetype)mutableCopy{
    return self;
}

@end
