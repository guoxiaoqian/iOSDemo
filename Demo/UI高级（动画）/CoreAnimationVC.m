//
//  CoreAnimationVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/3/19.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "CoreAnimationVC.h"

@interface MyLayer : CALayer

@end

@implementation MyLayer


-(void)setPosition:(CGPoint)position{
    [super setPosition:position];
}


@end

@interface MyView : UIView

@end

@implementation MyView

+(Class)layerClass{
    return [MyLayer class];
}

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event{
    id<CAAction> obj = [super actionForLayer:layer forKey:event];
    NSLog(@"%@",obj);
    return obj;
}

@end


@interface CoreAnimationVC ()

@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;

@end

@implementation CoreAnimationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    CAAnimation* basicAnimation = [self basicAnimation];
    [self.view1.layer addAnimation:basicAnimation forKey:nil];
    
    [self.view2.layer addAnimation:[self keyFrameAnimation] forKey:nil];
    
    [self.view3.layer addAnimation:[self groupAnimation] forKey:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CAAnimation*)basicAnimation{
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    //fromValue为id对象，由CG对象桥接而来；或者NSValue构造（值类型）
    animation.fromValue = (__bridge id)([UIColor yellowColor].CGColor);
    animation.toValue = (__bridge id)([UIColor greenColor].CGColor);
    animation.duration = 3;
    animation.beginTime = CACurrentMediaTime() + 1;
    animation.fillMode = kCAFillModeBackwards;
    
    return animation;
}

-(CAAnimation*)keyFrameAnimation{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    CATransform3D transform = CATransform3DIdentity;
    //value一定要有初始值（时间为0时）；Tranform要连续的话，需要基于上个Transform构造新的Transform
    animation.values = @[[NSValue valueWithCATransform3D:transform =  CATransform3DIdentity],
                         [NSValue valueWithCATransform3D:transform = CATransform3DTranslate(transform,100, 100, 0)],
                         [NSValue valueWithCATransform3D:transform = CATransform3DScale(transform,2, 2, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DRotate(transform,M_PI_2, 1, 0, 0)],
                         [NSValue valueWithCATransform3D:CATransform3DIdentity],
                         ];
    animation.keyTimes = @[@(0),@(0.3),@(0.5),@(0.7),@(1)];
    animation.duration = 3;
    animation.beginTime = CACurrentMediaTime() + 1;
    return  animation;
}

- (CAAnimation*)groupAnimation{
    CAAnimationGroup* group = [CAAnimationGroup animation];
    group.animations = @[[self basicAnimation],
                         [self keyFrameAnimation],
                         ];
    group.duration = 4;
#warning 第二个动画没有效果？
    return group;
}

-(void)viewBlockAnimation{
        
}

-(void)transitionAnimation{

}

-(void)shapeLayer{
    
}

-(void)displayLink{
    
}

@end
