//
//  PresentTransitioningDelegate.h
//  QQingCommon
//
//  Created by Ben on 15/8/26.
//  Copyright (c) 2015年 QQingiOSTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

// PresentAnimationNavigationController中使用，用于支持Present动画效果的pushViewController接口

@interface PresentTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@end


