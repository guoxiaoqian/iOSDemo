//
//  MRCTest.m
//  Demo
//
//  Created by 郭晓倩 on 2017/8/9.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "MRCTest.h"
#import "ARCTest.h"

//#if ! __has_feature(objc_arc)
//#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
//#endif

#if __has_feature(objc_arc)
#error This file must be compiled with MRC. Use -fno-objc-arc flag (or convert project to MRC).
#endif

@interface MRCTest ()
@property (retain) NSNumber* num;
@property (retain) NSString* str;
@end

@implementation MRCTest

+(void)testMRC{
//    __block id block_obj = [[NSObject alloc]init];
//    id obj = [[NSObject alloc]init];
//
//    NSLog(@"***Block前****block_obj = [%p , %lu] , obj = [%p , %lu]", &block_obj ,(unsigned long)[block_obj retainCount] , &obj,(unsigned long)[obj retainCount]);
//
//    void (^myBlock)(void) = ^{
//        NSLog(@"***Block中****block_obj = [%p , %lu] , obj = [%p , %lu]", &block_obj ,(unsigned long)[block_obj retainCount] , &obj,(unsigned long)[obj retainCount]);
//    };
//
//    myBlock();
//
//    void (^myBlockCopy)(void) = [myBlock copy];
//    NSLog(@"***BlockCopy前****block_obj = [%p , %lu] , obj = [%p , %lu]", &block_obj ,(unsigned long)[block_obj retainCount] , &obj,(unsigned long)[obj retainCount]);
//    myBlockCopy();
    
    
    ARCTest* obj = nil;
    
    @autoreleasepool {
        obj = [ARCTest createObject];
        NSLog(@"count=========%d",obj.retainCount);
    }
    
    NSLog(@"count=========%d",obj.retainCount);
}

- (void)testMRCObj{
    @autoreleasepool {
        self.num = [[[NSNumber alloc] initWithInt:1] autorelease];
        NSLog(@"retainCount %zd",self.num.retainCount);
    };
    NSLog(@"retainCount %zd",self.num.retainCount);
    [self.num release];
    NSLog(@"retainCount %zd",self.num.retainCount);
    
    @autoreleasepool {
        _str = @"";
        [_str release];
        NSLog(@"str retainCount %zd",_str.retainCount);
    }
    NSLog(@"str retainCount %zd",_str.retainCount);
}
- (void)dealloc {
    [_str release];
    
    [super dealloc];
}

@end
