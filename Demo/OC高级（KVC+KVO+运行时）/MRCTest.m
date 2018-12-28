//
//  MRCTest.m
//  Demo
//
//  Created by 郭晓倩 on 2017/8/9.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "MRCTest.h"

//#if ! __has_feature(objc_arc)
//#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
//#endif

#if __has_feature(objc_arc)
#error This file must be compiled with MRC. Use -fno-objc-arc flag (or convert project to MRC).
#endif

@interface MRCTest ()
@property (retain) NSNumber* num;
@end

@implementation MRCTest

+(void)testMRC{
    __block id block_obj = [[NSObject alloc]init];
    id obj = [[NSObject alloc]init];
    
    NSLog(@"***Block前****block_obj = [%p , %lu] , obj = [%p , %lu]", &block_obj ,(unsigned long)[block_obj retainCount] , &obj,(unsigned long)[obj retainCount]);
    
    void (^myBlock)(void) = ^{
        NSLog(@"***Block中****block_obj = [%p , %lu] , obj = [%p , %lu]", &block_obj ,(unsigned long)[block_obj retainCount] , &obj,(unsigned long)[obj retainCount]);
    };
    
    myBlock();
    
    void (^myBlockCopy)(void) = [myBlock copy];
    NSLog(@"***BlockCopy前****block_obj = [%p , %lu] , obj = [%p , %lu]", &block_obj ,(unsigned long)[block_obj retainCount] , &obj,(unsigned long)[obj retainCount]);
    myBlockCopy();
}

- (void)testMRCObj{
    @autoreleasepool {
        self.num = [[[NSNumber alloc] initWithInt:1] autorelease];
        NSLog(@"retainCount %zd",self.num.retainCount);
    };
    NSLog(@"retainCount %zd",self.num.retainCount);
    [self.num release];
    NSLog(@"retainCount %zd",self.num.retainCount);
}

@end
