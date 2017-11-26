//
//  MRCTest.m
//  Demo
//
//  Created by 郭晓倩 on 2017/8/9.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "MRCTest.h"

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

@end
