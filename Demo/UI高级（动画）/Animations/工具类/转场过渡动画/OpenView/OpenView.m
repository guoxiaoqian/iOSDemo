//
//  OpenView.m
//  QQingCommon
//
//  Created by Ben on 16/11/4.
//  Copyright (c) 2015年 QQingiOSTeam. All rights reserved.
//

#import "OpenView.h"
#import <QuartzCore/QuartzCore.h>

@interface OpenView() <CAAnimationDelegate> {
    CATransformLayer *_flipLayer;
    CALayer *_frontLayer;
    CALayer *_backLayer;
    CALayer *_bottomLayer;
    BOOL _isOpen;
    CATransform3D _transform;
    NSInteger _animationCount;
}

- (CABasicAnimation *)animationScaleForOpen;
- (CABasicAnimation *)animationFlipForOpen;
- (CABasicAnimation *)animationShowForClose;
- (CABasicAnimation *)animationScaleForClose;
- (CABasicAnimation *)animationFlipForClose;
- (CABasicAnimation *)animationFadeForClose;

@end

@implementation OpenView
@synthesize duration = _duration;
@synthesize frontImage = _frontImage;
@synthesize backImage = _backImage;
@synthesize flipDelegate = _flipDelegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isOpen = YES;
        _duration = 0.5;
        
        self.backgroundColor = [UIColor clearColor];
        _flipLayer = [CATransformLayer layer];
        _flipLayer.anchorPoint = CGPointMake(0, 0.5);
        _flipLayer.frame = self.bounds;
        
        
        _backLayer = [CALayer layer];
        _backLayer.frame = self.bounds;
        _backLayer.doubleSided = NO;
        _backLayer.masksToBounds = YES;
        //_backLayer.cornerRadius = 3;
        _backLayer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
        [_flipLayer addSublayer:_backLayer];
        
        _frontLayer = [CALayer layer];
        _frontLayer.frame = self.bounds;
        _frontLayer.doubleSided = NO;
        _frontLayer.masksToBounds = YES;
        //need reset frame
        _frontLayer.frame = self.bounds;
        [_flipLayer addSublayer:_frontLayer];
        
        _bottomLayer = [CALayer layer];
        _bottomLayer.frame = self.bounds;
        _bottomLayer.doubleSided = NO;
        _bottomLayer.masksToBounds = YES;
        //_bottomLayer.anchorPoint = CGPointMake(0, 0.5);
        //need reset frame
        _bottomLayer.frame = self.bounds;
        [self.layer addSublayer:_bottomLayer];
        
        [self.layer addSublayer:_flipLayer];
        _animationCount = 0;
    }
    return self;
}

- (void)setBackLayerFrame:(CGRect)rect {
    _backLayer.frame = rect;
    _bottomLayer.frame = rect;
    _flipLayer.anchorPoint = CGPointMake((rect.origin.x - 0.0) / _flipLayer.bounds.size.width, 0.5);
    _flipLayer.frame = self.bounds;
}

- (void)setBackImage:(UIImage *)backImage {
    _backImage = backImage;
    _backLayer.contents = (id)[_backImage CGImage];
}

- (void)setBottomImage:(UIImage *)bottomImage {
    _bottomImage = bottomImage;
    _bottomLayer.contents = (id)[_bottomImage CGImage];
}

- (void)setFrontImage:(UIImage *)frontImage {
    _frontImage = frontImage;
    _frontLayer.contents = (id)[_frontImage CGImage];
}

- (void)flipOpen {
//    [_backLayer addAnimation:[self animationShowForClose] forKey:@"open"];
//    _animationCount++;
    
    [_flipLayer addAnimation:[self animationFlipForOpen] forKey:@"open"];
    _animationCount++;
    
    [self.layer addAnimation:[self animationScaleForOpen] forKey:@"open"];
    _animationCount++;
}

- (void)flipClose {
//    [_backLayer addAnimation:[self animationFadeForClose] forKey:@"close"];
//    _animationCount++;
    
    [self.layer addAnimation:[self animationScaleForClose] forKey:@"close"];
    _animationCount++;
    
    [_flipLayer addAnimation:[self animationFlipForClose] forKey:@"close"];
    _animationCount++;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    _animationCount--;
    if (_animationCount > 0) {
        return ;
    }
    
    if (_isOpen) {
        
        
        _isOpen = NO;
        if ([self.flipDelegate respondsToSelector:@selector(animationDidFinished)]) {
            [self.flipDelegate animationDidFinished];
        }
    } else {
        if ([self.flipDelegate respondsToSelector:@selector(animationDidFinished)]) {
            [self.flipDelegate animationDidFinished];
        }
        [_flipLayer removeAllAnimations];
        [self removeFromSuperview];
    }
}

- (void)openState {
    CGFloat selfHeight = 450.0f;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
    {
        selfHeight = 450.0f;
    }
    
    _isOpen = YES;
    CGFloat translationX = (160.0f - _backLayer.frame.size.width) / 2 - self.frame.origin.x - _backLayer.frame.origin.x + 160.0f;
    CGFloat translationY = (selfHeight - _backLayer.frame.size.height) / 2 - self.frame.origin.y - _backLayer.frame.origin.y;
    _transform = CATransform3DMakeTranslation( translationX, translationY, 0.0f);
    //_transform = CATransform3DRotate(_transform, M_PI/2, 0.0f, 1.0f, 0.0f);
    _transform = CATransform3DScale(_transform, 160.0f / _backLayer.frame.size.width, selfHeight / _backLayer.frame.size.height, 1.0);
    self.layer.transform = _transform;
    
    _flipLayer.transform = CATransform3DRotate(CATransform3DIdentity, -M_PI, 0.0f, 1.0f, 0.0f);
    
}

#pragma mark - animations

- (CABasicAnimation *)animationScaleForOpen {
    CGFloat selfHeight = 450.0f;
    CGFloat selfHalfWidth = 160.0f;
    
    CGFloat translationX = selfHalfWidth + (selfHalfWidth - _backLayer.frame.size.width) / 2 - self.frame.origin.x - _backLayer.frame.origin.x;
    CGFloat translationY = (selfHeight - _backLayer.frame.size.height) / 2 - self.frame.origin.y - _backLayer.frame.origin.y;
    _transform = CATransform3DMakeTranslation(translationX, translationY, 0.0f);
    _transform = CATransform3DScale(_transform, selfHalfWidth / _backLayer.frame.size.width, selfHeight / _backLayer.frame.size.height, 1.0);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.duration = _duration;
    animation.delegate = self;
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:_transform];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    return animation;
}

- (CABasicAnimation *)animationFlipForOpen {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.duration = _duration;
    animation.delegate = self;
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(CATransform3DIdentity, -M_PI, 0.0f, 1.0f, 0.0f)];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    return animation;
}

- (CABasicAnimation *)animationShowForClose {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = _duration;
    animation.delegate = self;
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue = [NSNumber numberWithFloat:1.0];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    return animation;
}

- (CABasicAnimation *)animationScaleForClose {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.duration = _duration;
    animation.delegate = self;
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.fromValue = [NSValue valueWithCATransform3D:_transform];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    return animation;
}
- (CABasicAnimation *)animationFlipForClose {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.duration = _duration;
    animation.delegate = self;
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(CATransform3DIdentity, -M_PI, 0.0f, 1.0f, 0.0f)];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    return animation;
}

- (CABasicAnimation *)animationFadeForClose {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = _duration;
    animation.delegate = self;
    animation.toValue = [NSNumber numberWithFloat:0.0];
    animation.fromValue = [NSNumber numberWithFloat:1.0];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    return animation;
}

@end


