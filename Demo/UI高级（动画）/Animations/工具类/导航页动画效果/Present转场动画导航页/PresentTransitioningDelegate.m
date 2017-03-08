//
//  PresentTransitioningDelegate.m
//  QQingCommon
//
//  Created by Ben on 15/8/26.
//  Copyright (c) 2015年 QQingiOSTeam. All rights reserved.
//

#import "PresentTransitioningDelegate.h"

static const NSTimeInterval kPresentAnimationDuration = 0.3;

@interface PresentTransitioningDelegate ()

@property (nonatomic, assign) BOOL isInDismiss;

@end

@implementation PresentTransitioningDelegate

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.isInDismiss = NO;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.isInDismiss = YES;
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return kPresentAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey];
    UIView *containView = [transitionContext containerView];
   
    CGRect fromFinalRect = [transitionContext finalFrameForViewController:fromViewController];
    CGRect toFinalRect = [transitionContext finalFrameForViewController:toViewController];
    
    if ((fromFinalRect.size.width == 0) || (fromFinalRect.size.height == 0)) {
        fromFinalRect.size = toFinalRect.size;
    }
    
    if (!self.isInDismiss) {
        if (containView != toViewController.view) {
            [containView addSubview:toViewController.view];
        }
        toViewController.view.frame = CGRectMake(toFinalRect.size.width, 0, toFinalRect.size.width, toFinalRect.size.height);
        [UIView animateWithDuration:kPresentAnimationDuration animations:^{
            toViewController.view.frame = toFinalRect;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
        
    } else {
        if (containView != toViewController.view) {
            [containView insertSubview:toViewController.view atIndex:0];
        }
        [UIView animateWithDuration:kPresentAnimationDuration animations:^{
            fromViewController.view.frame = CGRectMake(fromFinalRect.size.width, 0, fromFinalRect.size.width, fromFinalRect.size.height);
        } completion:^(BOOL finished) {
            [fromViewController.view removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }
}

@end


