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
@property (strong, nonatomic) IBOutlet UIView *view5;
@property (strong, nonatomic) IBOutlet UIView *view6;
@property (strong, nonatomic) CALayer *layer;
@property (strong,nonatomic) UIImageView* imageView;
@property (assign,nonatomic) int displayLinkCount;
@property (strong,nonatomic) CAShapeLayer* shapeLayer;


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
    [self transitionAnimation];
    
    //    [self transaction];
    
    //        [self shapeLayerDemo];
    //
    //        [self displayLink];
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
    self.view6.frame = self.view5.frame;
    //    self.view5.hidden = YES;
    
    
    CATransition* transition = [CATransition animation];
    transition.startProgress = 0;
    transition.endProgress = 1.0;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    transition.duration = 2.0;
    
#pragma mark 基本Transition - 图层可见性
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Add the transition animation to both layers
        [self.view5.layer addAnimation:transition forKey:@"transition"];
        [self.view6.layer addAnimation:transition forKey:@"transition"];
        
        // Finally, change the visibility of the layers.
        self.view5.hidden = NO;
        self.view6.hidden = YES;
    });
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view5.layer addAnimation:transition forKey:@"transition"];
        [self.view6.layer addAnimation:transition forKey:@"transition"];
        [self.view exchangeSubviewAtIndex:[self.view.subviews indexOfObject:self.view5] withSubviewAtIndex:[self.view.subviews indexOfObject:self.view6]];
    });
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view5.layer addAnimation:transition forKey:@"transition"];
        [self.view6.layer addAnimation:transition forKey:@"transition"];
        
        [self.view6 removeFromSuperview];
        [self.view addSubview:self.view5];
    });
    
#pragma mark 基本Transition - content
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(200, 400, 100, 100)];
    [self.view addSubview:imageView];
    UIImage* image = [UIImage imageNamed:@"Demo"];
    UIImage* image2 = [UIImage imageNamed:@"Demo2"];
    imageView.image = image;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [imageView.layer addAnimation:transition forKey:nil];
        imageView.image = image2;
    });
    
#pragma mark UIView transition
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView beginAnimations:@"" context:nil];
        [UIView setAnimationDuration:2];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:imageView cache:YES];
        imageView.image = image;
        [UIView commitAnimations];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView transitionWithView:imageView duration:2 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            imageView.image = image2;
        } completion:^(BOOL finished) {
            
        }];
    });
    
    
#pragma mark - VC transition - 容器View切换
    
    UIViewController* chidVC = [UIViewController new];
    chidVC.view.backgroundColor = [UIColor greenColor];
    UIViewController* chidVC2 = [UIViewController new];
    chidVC2.view.backgroundColor = [UIColor redColor];
    
    [self addChildViewController:chidVC];
    [self addChildViewController:chidVC2];
    chidVC.view.frame = self.view.bounds;
    chidVC2.view.frame = self.view.bounds;
    [self.view addSubview:chidVC.view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [chidVC.view.layer addAnimation:transition forKey:nil];
        [chidVC2.view.layer addAnimation:transition forKey:nil];
        [chidVC.view removeFromSuperview];
        [self.view addSubview:chidVC2.view];
#warning chidVC 消失没有动画
    });
    
    //不能用系统提供的容器（TabBarController）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self transitionFromViewController:chidVC2 toViewController:chidVC duration:2 options:UIViewAnimationOptionTransitionCurlUp animations:^{
            [chidVC2.view removeFromSuperview];
            [self.view addSubview:chidVC.view];
        } completion:^(BOOL finished) {
            
        }];
    });
    
    
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

-(void)shapeLayerDemo{
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.fillColor = [UIColor greenColor].CGColor;
    self.shapeLayer.path = [self bezierPathWithHeight:100].CGPath;
    [self.view.layer addSublayer:self.shapeLayer];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.fromValue = (__bridge id)[self bezierPathWithHeight:100].CGPath;
        animation.toValue = (__bridge id)[self bezierPathWithHeight:300].CGPath;
        animation.duration = 3;
        [self.shapeLayer addAnimation:animation forKey:nil];
    });
    
}

-(UIBezierPath*)bezierPathWithHeight:(CGFloat)height{
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, kScreenWidth, height)];
    [path moveToPoint:CGPointMake(0, height)];
    [path addQuadCurveToPoint:CGPointMake(kScreenWidth, height) controlPoint:CGPointMake(kScreenWidth/2, height * 1.3)];
    [path closePath];
    //    [path fill];
    return path;
}

-(void)displayLink{
    
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(200, 505, 100, 100)];
    [self.view addSubview:self.imageView];
    
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(didDisplayLinkCome:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
}

-(void)didDisplayLinkCome:(CADisplayLink *)sender{
    if (self.displayLinkCount %60 == 0) {
        UIImage* image = [UIImage imageNamed:@"Demo"];
        UIImage* image2 = [UIImage imageNamed:@"Demo2"];
        self.imageView.image = (self.displayLinkCount / 60) % 2 == 0 ? image : image2;
    }
    self.displayLinkCount ++;
    
    if (self.displayLinkCount > 300) {
        [sender invalidate];
    }
    
}

@end
