//
//  Singleton.h
//  Demo
//
//  Created by 郭晓倩 on 2017/8/12.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - 完整单例

@interface Singleton : NSObject

+(void)testSingleton;

+(instancetype)sharedInstance;

@end

#pragma mark - 单例宏

//单例声明宏  （.h中用）
#define QD_DEC_SINGLETON( __class )                                      \
+ (__class *)getInstance;
//单例声明宏 END

//单例实现宏  （.m中用）
#define QD_IMP_SINGLETON( __class )                                      \
static __class* sInstance = nil;                                         \
\
+ (__class*)getInstance {                                             \
static dispatch_once_t predicate;                                        \
dispatch_once(&predicate, ^{                                             \
sInstance = [[self alloc] init];                                         \
});                                                                      \
return sInstance;                                                        \
}                                                                        \
\
+ (id)allocWithZone:(struct _NSZone *)zone {                             \
@synchronized(self) {                                                    \
if (sInstance == nil) {                                                  \
sInstance = [super allocWithZone:zone];                                  \
}                                                                        \
}                                                                        \
return sInstance;                                                        \
}                                                                        \
\
- (id)copyWithZone:(NSZone *)zone {                                      \
return self;                                                             \
}                                                                        \
\
- (id)mutableCopyWithZone:(NSZone *)zone {                               \
return self;                                                             \
}                                                                        \
//单例实现宏 宏结束


#pragma mark - 简单版单例


@interface Singleton2 : NSObject

+(instancetype)sharedInstance;

+ (instancetype)alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype)init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype)new    __attribute__((unavailable("new not available, call sharedInstance instead")));

@end
