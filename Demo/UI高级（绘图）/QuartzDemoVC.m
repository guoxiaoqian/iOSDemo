//
//  QuartzDemoVC.m
//  Demo
//
//  Created by 郭晓倩 on 17/3/8.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "QuartzDemoVC.h"

@interface QuartzDemoVC ()

@end

@implementation QuartzDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIStoryboard* storyBoard =  [UIStoryboard storyboardWithName:@"QuartzStoryboard" bundle:[NSBundle mainBundle]];
    UIViewController* entryVC = [storyBoard instantiateInitialViewController];
    [self.navigationController pushViewController:entryVC animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
