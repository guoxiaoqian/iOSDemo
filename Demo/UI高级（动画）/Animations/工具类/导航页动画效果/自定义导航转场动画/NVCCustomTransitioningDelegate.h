//
//  NVCCustomTransitioningDelegate.h
//  CustomNavTrans
//
//  Created by YuanBo on 4/25/16.
//  Copyright © 2016 YuanBo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 用于之前家长端帮我选弹出页面的动画效果

@interface NVCCustomTransitioningDelegate : NSObject<UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning>

@property (nonatomic, copy) Block pushCompleteBlock;
@property (nonatomic, copy) Block popCompleteBlock;

@end


