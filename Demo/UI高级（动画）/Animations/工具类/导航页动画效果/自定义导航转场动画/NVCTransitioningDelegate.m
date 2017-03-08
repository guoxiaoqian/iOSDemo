//
//  NVCTransitioningDelegate.h
//  QQingCommon
//
//  Created by Ben on 15/8/26.
//  Copyright (c) 2015年 QQingiOSTeam. All rights reserved.
//

#import "NVCTransitioningDelegate.h"

static const NSTimeInterval kAnimationDuration = 0.35;

@interface NVCTransitioningDelegate ()

@property (nonatomic, assign) UINavigationControllerOperation navigationControllerOperation;

@end

@implementation NVCTransitioningDelegate

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext;
{
    return kAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext;
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey];
    UIView *containView = [transitionContext containerView];
    
    if (self.navigationControllerOperation == UINavigationControllerOperationPush) {
        [containView addSubview:toViewController.view];
        toViewController.view.frame = CGRectMake(0, toViewController.view.frame.size.height, toViewController.view.frame.size.width, toViewController.view.frame.size.height);
        [UIView animateKeyframesWithDuration:kAnimationDuration delay:0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
            toViewController.view.frame = CGRectMake(0, 0, toViewController.view.frame.size.width, toViewController.view.frame.size.height);
        } completion:^(BOOL finished) {
            if (self.pushCompleteBlock) {
                self.pushCompleteBlock();
            }
            [transitionContext completeTransition:YES];
        }];
    } else if (self.navigationControllerOperation == UINavigationControllerOperationPop) {
        [containView insertSubview:toViewController.view atIndex:0];
        [UIView animateKeyframesWithDuration:kAnimationDuration delay:0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
            fromViewController.view.frame = CGRectMake(0, fromViewController.view.frame.size.height, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height);
        } completion:^(BOOL finished) {
            if (self.popCompleteBlock) {
                self.popCompleteBlock();
            }
            [fromViewController.view removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }
}

#pragma mark - UINavigationControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    self.navigationControllerOperation = operation;
    return self;
}

@end


