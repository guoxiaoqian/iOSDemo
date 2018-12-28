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

#pragma mark - MRC下

#if ! __has_feature(objc_arc)
- (id)retain {
    return self;
}

- (oneway void)release {
}

- (id)autorelease {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;
}
#endif

@end



@implementation Singleton2

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initInstance];
    });
    return sharedInstance;
}

- (id)initInstance{
    if (self = [super init]) {
        
    }
    return self;
}

@end
