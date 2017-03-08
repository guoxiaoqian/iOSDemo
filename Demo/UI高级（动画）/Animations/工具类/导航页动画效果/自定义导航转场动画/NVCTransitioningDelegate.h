//
//  NVCTransitioningDelegate.h
//  QQingCommon
//
//  Created by Ben on 15/8/26.
//  Copyright (c) 2015年 QQingiOSTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

// 用于之前家长端帮我选弹出页面的动画效果

@interface NVCTransitioningDelegate : NSObject<UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning>

@property (nonatomic, copy) Block pushCompleteBlock;
@property (nonatomic, copy) Block popCompleteBlock;

@end


