//
//  NVCCustomTransitioningDelegate.m
//  CustomNavTrans
//
//  Created by YuanBo on 4/25/16.
//  Copyright © 2016 YuanBo. All rights reserved.
//

#import "NVCCustomTransitioningDelegate.h"

static const NSTimeInterval kAnimationDuration = 1;

@interface NVCCustomTransitioningDelegate ()

@property (nonatomic, assign) UINavigationControllerOperation navigationControllerOperation;

@end

@implementation NVCCustomTransitioningDelegate

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
        //---解决角度变换时，fromVC有一半会出现在 toVC上的bug
        fromViewController.view.layer.zPosition = -1000;
        toViewController.view.layer.zPosition = 1000;
        
        //---初始化弹出视图在底部
        toViewController.view.frame =  CGRectMake(0, toViewController.view.frame.size.height, toViewController.view.frame.size.width, toViewController.view.frame.size.height);
        
        [containView addSubview:toViewController.view];
        
        [UIView animateWithDuration:kAnimationDuration/2.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [fromViewController.view.layer setTransform:[self firstTransform]];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:kAnimationDuration/2.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [fromViewController.view.layer setTransform:[self secondTransform]];
            } completion:^(BOOL finished) {
            }];
            
        }];
        
        [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            toViewController.view.frame = CGRectMake(0, 0, toViewController.view.frame.size.width, toViewController.view.frame.size.height);
        } completion:^(BOOL finished) {
            if (self.pushCompleteBlock) {
                self.pushCompleteBlock();
            }
            [transitionContext completeTransition:YES];
        }];
        
    } else if (self.navigationControllerOperation == UINavigationControllerOperationPop) {
        [containView insertSubview:toViewController.view atIndex:0];
        //---获得当前frame
        toViewController.view.frame = [UIScreen mainScreen].bounds;
        CGRect finalRect = CGRectMake(0, 2 * fromViewController.view.frame.size.height, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height);
        
        [UIView animateWithDuration:kAnimationDuration/2.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [toViewController.view.layer setTransform:[self firstTransform]];
            
            if (self.popCompleteBlock) {
                self.popCompleteBlock();
            }
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:kAnimationDuration/2.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [toViewController.view.layer setTransform:CATransform3DIdentity];
            } completion:^(BOOL finished) {
            }];
        }];
        
        [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            fromViewController.view.frame = finalRect;
        } completion:^(BOOL finished) {
            
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


#pragma mark - 变换操作
//---第一步变换
- (CATransform3D )firstTransform
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0/ -900;
    //---宽高缩小0.9
    transform = CATransform3DScale(transform, 0.95, 0.95, 1);
    //---绕X轴旋转15度
    transform = CATransform3DRotate(transform, 15.0 * M_PI / 180.0 , 1, 0, 0);
    
    return transform;
}

//---第二步变换
- (CATransform3D )secondTransform
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = [self firstTransform].m34;
    //---向上移动的高度
    transform = CATransform3DTranslate(transform, 0, -20 , 0);
    //---宽高缩小0.8
    transform = CATransform3DScale(transform, 0.8, 0.8, 1);
    
    return transform;
}


@end


