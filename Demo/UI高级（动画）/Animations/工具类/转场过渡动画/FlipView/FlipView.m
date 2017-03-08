//
//  FlipView.m
//  QQingCommon
//
//  Created by Ben on 16/11/4.
//  Copyright (c) 2015年 QQingiOSTeam. All rights reserved.
//

#import "FlipView.h"
#import <QuartzCore/QuartzCore.h>

@interface FlipView() <CAAnimationDelegate> {
    CATransformLayer *_flipLayer;
    CALayer *_frontLayer;
    CALayer *_backLayer;
    BOOL _isOpen;
    CATransform3D _transform;
}

@end

@implementation FlipView
@synthesize frontImage = _frontImage;
@synthesize backImage = _backImage;
@synthesize flipDelegate = _flipDelegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isOpen = YES;
        
        self.backgroundColor = [UIColor clearColor];
        _flipLayer = [CATransformLayer layer];
        _flipLayer.frame = self.bounds;
        [self.layer addSublayer:_flipLayer];
        
        _backLayer = [CALayer layer];
        _backLayer.frame = self.bounds;
        _backLayer.doubleSided = NO;
        _backLayer.masksToBounds = YES;
        _backLayer.transform = CATransform3DMakeRotation(-M_PI, 0.0f, 1.0f, 0.0f);
        [_flipLayer addSublayer:_backLayer];
        
        _frontLayer = [CALayer layer];
        _frontLayer.frame = self.bounds;
        _frontLayer.doubleSided = NO;
        _frontLayer.masksToBounds = YES;
        [_flipLayer addSublayer:_frontLayer];
    }
    return self;
}

- (void)setBackImage:(UIImage *)backImage {
    _backImage = backImage;
    _backLayer.contents = (id)[_backImage CGImage];
}

- (void)setFrontImage:(UIImage *)frontImage {
    _frontImage = frontImage;
    _frontLayer.contents = (id)[_frontImage CGImage];
}

- (void)flipOpen {
    _transform = CATransform3DIdentity;
    _transform = CATransform3DRotate(_transform, -M_PI, 1.0f, 0.0f, 0.0f);
    _transform.m34 = -1.0/500;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.7;
    animation.delegate = self;
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:_transform];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [_flipLayer addAnimation:animation forKey:@"open"];
}

- (void)flipClose {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.7;
    animation.delegate = self;
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.fromValue = [NSValue valueWithCATransform3D:_transform];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [_flipLayer addAnimation:animation forKey:@"close"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (_isOpen) {
        _isOpen = NO;
        if ([self.flipDelegate respondsToSelector:@selector(animationDidFinished)]) {
            [self.flipDelegate animationDidFinished];
        }
    } else {
        [_flipLayer removeAllAnimations];
        if ([self.flipDelegate respondsToSelector:@selector(animationAllFinished)]) {
            [self.flipDelegate animationAllFinished];
        }
        [self removeFromSuperview];
    }
}

- (BOOL)isOpen {
    return _isOpen;
}

@end


