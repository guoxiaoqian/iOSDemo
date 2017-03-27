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

-(id<CAAction>)actionForKey:(NSString *)event{
    id action = [super actionForKey:event];
    id defaultAction = [[self class] defaultActionForKey:event];
    NSLog(@"actionForKey:%@ action:%@ defaultAction:%@",event,action,defaultAction);
    if ([event isEqualToString:@"position"]) {
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(100, 50)];
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(100, 500)];
//        animation.duration = 10;
        animation.repeatCount = 10;
        return animation;
    }else if([event isEqualToString:@"backgroundColor"]){
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        animation.fromValue = (__bridge id)[UIColor redColor].CGColor;
        animation.toValue = (__bridge id)[UIColor blueColor].CGColor;
//        animation.duration = 3;
        animation.repeatCount = 10;
        return animation;
    }
    return action;
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

-(void)drawRect:(CGRect)rect{
    
    NSLog(@"MyView.drawRect.layer.contents %@",self.layer.contents);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor redColor] setStroke];
    [[UIColor blueColor] setFill];
    CGContextSetLineWidth(context, 2);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    //****划线
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 100, 100);
    CGContextAddRect(context, CGRectMake(0, 0, 100, 100));
    CGContextStrokePath(context);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"MyView.ater.drawRect.layer.contents %@",self.layer.contents);
    });
}

-(void)didMoveToWindow{
    if (self.window) {
        NSLog(@"MyView.didMoveToWindow.layer.contents %@",self.layer.contents);
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    NSLog(@"MyView.layoutSubviews.layer.contents %@",self.layer.contents);
}

@end


@interface CoreAnimationVC ()

@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIView *view4;
@property (weak, nonatomic) IBOutlet UIView *view5;
@property (strong, nonatomic) CALayer *layer;

@end

@implementation CoreAnimationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
//    CAAnimation* basicAnimation = [self basicAnimation];
//    [self.view1.layer addAnimation:basicAnimation forKey:nil];
//    
//    [self.view2.layer addAnimation:[self keyFrameAnimation] forKey:nil];
    
//    [self.view3.layer addAnimation:[self groupAnimation] forKey:nil];
//    
//    [self viewBlockAnimation];
//    
//    [self transitionAnimation];
    
    [self transaction];
    
//    [self shapeLayer];
//    
//    [self displayLink];
//    
//    NSLog(@"view.layer.contents %@",self.view.layer.contents);
////    [self.view.layer setContents:(__bridge id)[UIImage imageNamed:@"Demo"].CGImage];
////    NSLog(@"view.layer.contents %@",self.view.layer.contents);
//    
//    
//    MyView* myView = [[MyView alloc] initWithFrame:CGRectMake(200, 200, 100, 100)];
//    [self.view addSubview:myView];
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
    //    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    //    CATransform3D transform = CATransform3DIdentity;
    //value一定要有初始值（时间为0时）；Tranform要连续的话，需要基于上个Transform构造新的Transform
    //    animation.values = @[[NSValue valueWithCATransform3D:transform =  CATransform3DIdentity],
    //                         [NSValue valueWithCATransform3D:transform = CATransform3DTranslate(transform,100, 100, 0)],
    //                         [NSValue valueWithCATransform3D:transform = CATransform3DScale(transform,2, 2, 1)],
    //                         [NSValue valueWithCATransform3D:CATransform3DRotate(transform,M_PI_2, 1, 0, 0)],
    //                         [NSValue valueWithCATransform3D:CATransform3DIdentity],
    //                         ];
    //    animation.keyTimes = @[@(0),@(0.3),@(0.5),@(0.7),@(1)];
    
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(100, 100, 200, 200)].CGPath;
    
    animation.duration = 3;
    animation.beginTime = CACurrentMediaTime() + 1;
    return  animation;
}

- (CAAnimation*)groupAnimation{
    CAAnimationGroup* group = [CAAnimationGroup animation];
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    //fromValue为id对象，由CG对象桥接而来；或者NSValue构造（值类型）
    animation.fromValue = (__bridge id)([UIColor yellowColor].CGColor);
    animation.toValue = (__bridge id)([UIColor greenColor].CGColor);
    animation.duration = 2;
    CAKeyframeAnimation* animation2 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation2.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(100, 100, 200, 200)].CGPath;
    animation2.duration = 1;
    animation2.beginTime = 3;
    
//    group.animations = @[[self basicAnimation],
//                         [self keyFrameAnimation],
//                         ];
    group.animations = @[animation,
                         animation2,
                         ];
    group.duration = 4;
    group.beginTime = CACurrentMediaTime() + 3;

//group的周期不改变子animation的周期，若子animation周期过长，动画会被截断。
//子animation的beginTime是与group的beginTime的相对时间，不能加CACurrentMediaTime()。
    
    return group;
}

-(void)viewBlockAnimation{
    [UIView animateWithDuration:3 delay:1 options:UIViewAnimationOptionRepeat | UIViewAnimationCurveLinear | UIViewAnimationOptionAutoreverse animations:^{
        self.view4.backgroundColor = [UIColor redColor];
        self.view4.center = CGPointMake(100, 400);
    } completion:^(BOOL finished) {
        
    }];
}

-(void)transitionAnimation{
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    transition.startProgress = 0;
    transition.endProgress = 1;
    transition.duration = 3;
    [self.view5.layer addAnimation:transition forKey:nil];
}

-(void)transaction{
    self.layer = [MyLayer layer];
    self.layer.frame = CGRectMake(200, 400, 100, 100);
    self.layer.backgroundColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:self.layer];
    
#warning CALayer的属性修改，为啥返回的action都为null ???
    
    [CATransaction begin];
    NSLog(@"CATransaction begin");
    //改的是默认动画时间，即action没有设置动画时间时，才会采用默认时间；action动画时间超过默认时间，不会被中断
    [CATransaction setAnimationDuration:3];
    [CATransaction setDisableActions:NO];
    self.layer.backgroundColor = [UIColor yellowColor].CGColor;
    self.layer.position = CGPointMake(100, 100);
    [CATransaction setCompletionBlock:^{
        NSLog(@"CATransaction complete");
    }];
    [CATransaction commit];
}

-(void)shapeLayer{
    
}

-(void)displayLink{
    
}

@end
