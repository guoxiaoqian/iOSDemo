//
//  UIView+AnimationUtility.h
//  QQingCommon
//
//  Created by Ben on 2016/11/16.
//  Copyright © 2016年 QQingiOSTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AnimationUtility)

- (void)fadeIn;

- (void)fadeInWithDuration:(float)duration;

- (void)fadeInWithDuration:(float)duration completion:(void(^)(BOOL finished))completion;

- (void)fadeOut;

- (void)fadeOutWithDuration:(float)duration;

- (void)fadeOutWithDuration:(float)duration completion:(void(^)(BOOL finished))completion;

- (void)showAnimationWithType:(NSString *)type
                  withSubType:(NSString *)subType
                     duration:(CFTimeInterval)duration
               timingFunction:(NSString *)timingFunction
            animationDelegate:(id <CAAnimationDelegate>)delegate
                 animationKey:(NSString *)animationKey;

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

/** type <-> subType
 *    type                          subType
 *
 *    moveIn/push/reveal            fromLeft, fromRight, fromBottom, fromTop
 *    pageCurl, pageUnCurl          fromLeft, fromRight, fromTop, fromBottom
 *    cube/alignedCube              fromLeft, fromRight, fromTop, fromBottom
 *    flip/alignedFlip/oglFlip      fromLeft, fromRight, fromTop, fromBottom
 *    cameraIris                        -
 *    rippleEffect                      -
 *    rotate                        90cw, 90ccw, 180cw, 180ccw
 *    suckEffect                        -
 */

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
+ (void)showAnimationWithType:(NSString *)type
                  withSubType:(NSString *)subType
                     duration:(CFTimeInterval)duration
               timingFunction:(NSString *)timingFunction
            animationDelegate:(id <CAAnimationDelegate>)delegate
                       onView:(UIView *)theView
                 animationKey:(NSString *)animationKey;

@end


