//
//  ImageDecodeVC.m
//  Demo
//
//  Created by gavinxqguo on 2021/4/30.
//  Copyright © 2021 郭晓倩. All rights reserved.
//

#import "ImageDecodeVC.h"
#import "SystemInfoVC.h"

@interface ImageDecodeVC ()

@end

@implementation ImageDecodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self testImageLoad];
}

- (void)testImageLoad {
    NSString* strAbsolutePath=[[NSBundle mainBundle] pathForResource:@"sendingBmp" ofType:@"gif"];
  
    NSLog(@"befor image load memory %.4fk",[SystemInfoVC usedMemory]);
    UIImage* image = [UIImage imageWithContentsOfFile:strAbsolutePath];
    NSLog(@"after image load  %.4fk",[SystemInfoVC usedMemory]);
    NSData* data = [NSData dataWithContentsOfFile:strAbsolutePath];
    NSLog(@"after data load  %.4fk",[SystemInfoVC usedMemory]);

}

@end
