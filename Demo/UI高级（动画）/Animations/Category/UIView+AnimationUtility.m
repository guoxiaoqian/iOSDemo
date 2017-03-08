//
//  UIView+AnimationUtility.m
//  QQingCommon
//
//  Created by Ben on 2016/11/16.
//  Copyright © 2016年 QQingiOSTeam. All rights reserved.
//

#import "UIView+AnimationUtility.h"

@implementation UIView (AnimationUtility)

- (void)fadeIn {
    [self fadeInWithDuration:0.3];
}

- (void)fadeInWithDuration:(float)duration {
    [self fadeInWithDuration:duration completion:nil];
}

- (void)fadeInWithDuration:(float)duration completion:(void(^)(BOOL finished))completion {
    float originAlpha = 1;
    
    self.alpha = 0;
    [UIView animateWithDuration:duration animations:^{
        self.alpha = originAlpha;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)fadeOut {
    [self fadeOutWithDuration:0.3];
}

- (void)fadeOutWithDuration:(float)duration {
    [self fadeOutWithDuration:duration completion:nil];
}

- (void)fadeOutWithDuration:(float)duration completion:(void(^)(BOOL finished))completion {
    float originAlpha = 1;
    
    if (self.hidden == YES) {
        self.alpha = 0;
    }
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.alpha = originAlpha;
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)showAnimationWithType:(NSString *)type
                  withSubType:(NSString *)subType
                     duration:(CFTimeInterval)duration
               timingFunction:(NSString *)timingFunction
            animationDelegate:(id <CAAnimationDelegate>)delegate
                 animationKey:(NSString *)animationKey {
    [UIView showAnimationWithType:type
                      withSubType:subType
                         duration:duration
                   timingFunction:timingFunction
                animationDelegate:delegate
                           onView:self
                     animationKey:animationKey];
}

+ (void)showAnimationWithType:(NSString *)type
                  withSubType:(NSString *)subType
                     duration:(CFTimeInterval)duration
               timingFunction:(NSString *)timingFunction
            animationDelegate:(id <CAAnimationDelegate>)delegate
                       onView:(UIView *)theView
                 animationKey:(NSString *)animationKey {
    CATransition *animation = [CATransition animation];
    /** delegate
     *
     *  动画的代理,如果你想在动画开始和结束的时候做一些事,可以设置此属性,它会自动回调两个代理方法.
     */
    
    animation.delegate = delegate;
    
    /**
     *  动画持续时间
     */
    animation.duration = duration;
    
    /** timingFunction
     *
     *  用于变化起点和终点之间的插值计算,形象点说它决定了动画运行的节奏,比如是均匀变化(相同时间变化量相同)还是
     *  先快后慢,先慢后快还是先慢再快再慢.
     *
     *  动画的开始与结束的快慢,有五个预置分别为(下同):
     *  kCAMediaTimingFunctionLinear            线性,即匀速
     *  kCAMediaTimingFunctionEaseIn            先慢后快
     *  kCAMediaTimingFunctionEaseOut           先快后慢
     *  kCAMediaTimingFunctionEaseInEaseOut     先慢后快再慢
     *  kCAMediaTimingFunctionDefault           实际效果是动画中间比较快.
     */
    
    /** timingFunction
     *
     *  自定义动画运行函数使用下面的方法
     *
     *  + (id)functionWithControlPoints:(float)c1x :(float)c1y :(float)c2x :(float)c2y;
     *
     *  - (id)initWithControlPoints:(float)c1x :(float)c1y :(float)c2x :(float)c2y;
     */
    animation.timingFunction = [CAMediaTimingFunction functionWithName:timingFunction];
    
    animation.autoreverses = YES;
    animation.fillMode = kCAFillModeBackwards;
    
    /** removedOnCompletion
     *
     *  这个属性默认为YES.一般情况下,不需要设置这个属性.
     *
     *  但如果是CAAnimation动画,并且需要设置 fillMode 属性,那么需要将 removedOnCompletion 设置为NO,否则
     *  fillMode无效
     */
    
    animation.removedOnCompletion = NO;
    
    
    /** type
     *
     *  各种动画效果  其中除了'fade'=kCATransitionFade, `moveIn'=kCATransitionMoveIn, `push'=kCATransitionPush , `reveal'=kCATransitionReveal ,其他属于私有的API.
     *
     *  @"cube"                     立方体翻滚效果
     *  @"moveIn"                   新视图移到旧视图上面
     *  @"reveal"                   显露效果(将旧视图移开,显示下面的新视图)
     *  @"fade"                     交叉淡化过渡(不支持过渡方向)             (默认为此效果)
     *  @"pageCurl"                 向上翻一页
     *  @"pageUnCurl"               向下翻一页
     *  @"suckEffect"               收缩效果，类似系统最小化窗口时的神奇效果(不支持过渡方向)
     *  @"rippleEffect"             滴水效果,(不支持过渡方向)
     *  @"oglFlip"                  上下左右翻转效果
     *  @"rotate"                   旋转效果
     *  @"push"
     *  @"cameraIrisHollowOpen"     相机镜头打开效果(不支持过渡方向)
     *  @"cameraIrisHollowClose"    相机镜头关上效果(不支持过渡方向)
     */
    
    animation.type = type;
    //-----------------------------------------------------------------
    //    Transition                                Subtypes
    //
    //    moveIn/push/reveal            fromLeft, fromRight, fromBottom, fromTop
    //    pageCurl, pageUnCurl          fromLeft, fromRight, fromTop, fromBottom
    //    cube/alignedCube              fromLeft, fromRight, fromTop, fromBottom
    //    flip/alignedFlip/oglFlip      fromLeft, fromRight, fromTop, fromBottom
    //    cameraIris                        -
    //    rippleEffect                      -
    //    rotate                        90cw, 90ccw, 180cw, 180ccw
    //    suckEffect                        -
    
    /** subtype
     *
     *  各种动画方向
     *
     *  kCATransitionFromRight;      同字面意思(下同)
     *  kCATransitionFromLeft;
     *  kCATransitionFromTop;
     *  kCATransitionFromBottom;
     */
    
    /** subtype
     *
     *  当type为@"rotate"(旋转)的时候,它也有几个对应的subtype,分别为:
     *  90cw    逆时针旋转90°
     *  90ccw   顺时针旋转90°
     *  180cw   逆时针旋转180°
     *  180ccw  顺时针旋转180°
     */
    
    /**
     *  type与subtype的对应关系(必看),如果对应错误,动画不会显现.有一个地址在下面可以查看效果： http://iphonedevwiki.net/index.php/CATransition
     */
    animation.subtype = subType;
    
    //用于使动画在
    //    animation.startProgress = 0.4;
    //    animation.endProgress = 0.8;
    
    /**
     *  所有核心动画和特效都是基于CAAnimation,而CAAnimation是作用于CALayer的.所以把动画添加到layer上.
     *  forKey  可以是任意字符串.
     */
    [theView.layer addAnimation:animation forKey:animationKey ? animationKey : @""];
}

@end


