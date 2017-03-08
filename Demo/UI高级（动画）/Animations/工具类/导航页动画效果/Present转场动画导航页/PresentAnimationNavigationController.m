//
//  PresentAnimationNavigationController.m
//  QQingCommon
//
//  Created by Ben on 15/8/26.
//  Copyright (c) 2015年 QQingiOSTeam. All rights reserved.
//

#import "PresentAnimationNavigationController.h"

@interface PresentAnimationNavigationController ()

@property (nonatomic, strong) PresentTransitioningDelegate *presentTransitioningDelegate;

@end

@implementation PresentAnimationNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        self.presentTransitioningDelegate = [PresentTransitioningDelegate new];
        self.transitioningDelegate = self.presentTransitioningDelegate;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


