//
//  TestGeneralAnimationVC.m
//  QQing
//
//  Created by Ben on 2016/11/16.
//
//

#import "TestGeneralAnimationVC.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+AnimationUtility.h"

@interface TestGeneralAnimationVC () <CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollContentViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *testCategoryView;
@property (weak, nonatomic) IBOutlet UIView *testCABaseAnimationView;
@property (weak, nonatomic) IBOutlet UIView *testCAKeyframeAnimationView;
@property (weak, nonatomic) IBOutlet UIView *testCATransitionView;
@property (weak, nonatomic) IBOutlet UIView *testCAAnimationGroupView;

@property (weak, nonatomic) IBOutlet UIView *testUIViewAnimationView;
@property IBOutlet UILabel *greenLabel;
@property IBOutlet UILabel *blueLabel;
@property IBOutlet UILabel *yellowLabel;


@end

@implementation TestGeneralAnimationVC

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.scrollContentViewHeightConstraint.constant = 1300;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)didClickTestCategoryButtonAction:(id)sender {
    [self.testCategoryView fadeOutWithDuration:1 completion:^(BOOL finished) {
        [self.testCategoryView fadeInWithDuration:1];
    }];
}

- (IBAction)didClickTestCABaseAnimationButtonAction:(id)sender {
    NSInteger btnTag = ((UIButton *)sender).tag;
    if (btnTag == 1) {
        [self changeColorWithBaseAnimation];
    } else {
        [self transformWithBaseAnimation];
    }
}

- (IBAction)didClickTestCAKeyframeAnimationButtonAction:(id)sender {
    NSInteger btnTag = ((UIButton *)sender).tag;
    if (btnTag == 1) {
        [self changeColorWithKeyFrameAnimation];
    } else if (btnTag == 2) {
        [self shakeViewWithKeyFrameAnimation];
    } else {
        [self keyFrameAnimationWithBezierPath];
    }
}

- (IBAction)didClickTestCATransitionButtonAction:(id)sender {
//    *  @"cube"                     立方体翻滚效果
//    *  @"moveIn"                   新视图移到旧视图上面
//    *  @"reveal"                   显露效果(将旧视图移开,显示下面的新视图)
//    *  @"fade"                     交叉淡化过渡(不支持过渡方向)             (默认为此效果)
//    *  @"pageCurl"                 向上翻一页
//    *  @"pageUnCurl"               向下翻一页
//    *  @"suckEffect"               收缩效果，类似系统最小化窗口时的神奇效果(不支持过渡方向)
//    *  @"rippleEffect"             滴水效果,(不支持过渡方向)
//    *  @"oglFlip"                  上下左右翻转效果
//    *  @"rotate"                   旋转效果
//    *  @"push"
//    *  @"cameraIrisHollowOpen"     相机镜头打开效果(不支持过渡方向)
//    *  @"cameraIrisHollowClose"    相机镜头关上效果(不支持过渡方向)
    
    UIButton *button = (UIButton *)sender;
    NSUInteger btnTag = button.tag;
    
    NSString *type = @"cube";
    switch (btnTag) {
        case 1: {
            type = @"cube";
        }
            break;
        case 2: {
            type = @"moveIn";
        }
            break;
        case 3: {
            type = @"reveal";
        }
            break;
        case 4: {
            type = @"fade";
        }
            break;
        case 5: {
            type = @"pageCurl";
        }
            break;
        case 6: {
            type = @"pageUnCurl";
        }
            break;
        case 7: {
            type = @"suckEffect";
        }
            break;
        case 8: {
            type = @"rippleEffect";
        }
            break;
        case 9: {
            type = @"oglFlip";
        }
            break;
        case 10: {
            type = @"rotate";
        }
            break;
        case 11: {
            type = @"push";
        }
            break;
        case 12: {
            type = @"cameraIrisHollowOpen";
        }
            break;
        case 13: {
            type = @"cameraIrisHollowClose";
        }
            break;
    }
    
    [button showAnimationWithType:type
                      withSubType:@"fromLeft"
                         duration:2.0
                   timingFunction:kCAMediaTimingFunctionEaseInEaseOut
                animationDelegate:self
                     animationKey:type];
}

- (IBAction)didClickTestCAAnimationGroupButtonAction:(id)sender {
    [self groupAnimationRotateAndScaleDownUp];
}

- (IBAction)didClickTestUIViewAnimationButtonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSUInteger btnTag = button.tag;
    switch (btnTag) {
        case 1: {
            [self viewAnimation];
        }
            break;
        case 2: {
            [self viewAnimationWithKeyFrame];
        }
            break;
        case 3: {
            [self viewAnimationWithTransition];
        }
            break;
        case 4: {
            [self viewAnimationWithSpring];
        }
            break;
        default: {
            return;
        }
    }
}

#pragma mark -- CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim {
    NSLog(@"动画开始");
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSLog(@"动画结束啦");
}

#pragma mark - CABaseAnimation
/**
 *  CABasicAnimation
 *
 *  @brief                      便利构造函数 animationWithKeyPath: KeyPath需要一个字符串类型的参数,实际上是一个
 *                              键-值编码协议的扩展,参数必须是CALayer的某一项属性,你的代码会对应的去改变该属性的效果
 *
 *                              例如这里填写的是 @"transform.rotation.z" 意思就是围绕z轴旋转,旋转的单位是弧度.
 *                              你也可以填写@"opacity" 去修改透明度...以此类推.修改layer的属性,可以用这个类.
 *
 *  @param toValue              动画结束的值.CABasicAnimation自己只有三个属性(都很重要)(其他属性是继承来的),分别为:
 *                              fromValue(开始值), toValue(结束值), byValue(偏移值),
 !                              这三个属性最多只能同时设置两个;
 *                              他们之间的关系如下:
 *                              如果同时设置了fromValue和toValue,那么动画就会从fromValue过渡到toValue;
 *                              如果同时设置了fromValue和byValue,那么动画就会从fromValue过渡到fromValue + byValue;
 *                              如果同时设置了byValue  和toValue,那么动画就会从toValue - byValue过渡到toValue;
 *
 *                              如果只设置了fromValue,那么动画就会从fromValue过渡到当前的value;
 *                              如果只设置了toValue  ,那么动画就会从当前的value过渡到toValue;
 *                              如果只设置了byValue  ,那么动画就会从从当前的value过渡到当前value + byValue.
 *
 *                              可以这么理解,当你设置了三个中的一个或多个,系统就会根据以上规则使用插值算法计算出一个时间差并
 *                              同时开启一个Timer.Timer的间隔也就是这个时间差,通过这个Timer去不停地刷新keyPath的值.
 !                              而实际上,keyPath的值(layer的属性)在动画运行这一过程中,是没有任何变化的,它只是调用了GPU去
 *                              完成这些显示效果而已.
 *                              在这个动画里,是设置了要旋转到的弧度,根据以上规则,动画将会从它当前的弧度专旋转到我设置的弧度.
 *
 *  @param duration             动画持续时间
 *
 *  @param fillMode         决定当前对象过了非active时间段的行为,比如动画开始之前,动画结束之后.
 *      预置为:
 *      kCAFillModeRemoved   默认,当动画开始前和动画结束后,动画对layer都没有影响,动画结束后,layer会恢复到之前的状态
 *      kCAFillModeForwards  当动画结束后,layer会一直保持着动画最后的状态
 *      kCAFillModeBackwards 和kCAFillModeForwards相对,具体参考上面的URL
 *      kCAFillModeBoth      kCAFillModeForwards和kCAFillModeBackwards在一起的效果
 *
 *  @param timingFunction       动画起点和终点之间的插值计算,也就是说它决定了动画运行的节奏,是快还是慢,还是先快后慢...
 */
- (void)changeColorWithBaseAnimation {
    //随机颜色变化
    CGFloat red = arc4random() / (CGFloat)INT_MAX;
    CGFloat green = arc4random() / (CGFloat)INT_MAX;
    CGFloat blue = arc4random() / (CGFloat)INT_MAX;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:0.5];
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.duration = 2.0f;
    animation.keyPath = @"backgroundColor";
    animation.fromValue = (__bridge id)(self.testCABaseAnimationView.backgroundColor.CGColor);
    animation.toValue = (__bridge id)color.CGColor;
    animation.delegate = self;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeBoth;
    animation.autoreverses = YES;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.testCABaseAnimationView.layer addAnimation:animation forKey:@"changeColorWithBaseAnimation"];
}

- (void)transformWithBaseAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0.0)];
    animation.duration = 0.45;
    animation.repeatCount = 1;
    animation.removedOnCompletion = YES;
    animation.autoreverses = YES;
    [self.testCABaseAnimationView.layer addAnimation:animation forKey:@"transformWithBaseAnimation"];
}

#pragma mark - CAKeyframeAnimation

- (void)changeColorWithKeyFrameAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"backgroundColor"];
    animation.duration = 2.0;
    animation.values = @[(__bridge id)[UIColor blueColor].CGColor,
                         (__bridge id)[UIColor redColor].CGColor,
                         (__bridge id)[UIColor greenColor].CGColor,
                         (__bridge id)[UIColor blueColor].CGColor ];
    CAMediaTimingFunction *fn = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.timingFunctions = @[fn, fn, fn];
    animation.calculationMode = @"cubic";
    animation.autoreverses = YES;
    animation.keyTimes = @[@0.0,@0.5,@0.9,@1.0];
    [self.testCAKeyframeAnimationView.layer addAnimation:animation forKey:@"changeColorWithKeyFrameAnimation"];
}

- (void)shakeViewWithKeyFrameAnimation {
    CAKeyframeAnimation * anima=[CAKeyframeAnimation animation];
    //通过设置放射变换的角度来实现
    anima.keyPath = @"transform.rotation";
    float p1 = 10/180.0*M_PI;
    anima.duration = 1;
    anima.values = @[@(-p1),@(p1),@(-p1)];
    anima.fillMode = kCAFillModeForwards;
    anima.removedOnCompletion = NO;
    anima.repeatCount = MAXFLOAT;
    [self.testCAKeyframeAnimationView.layer addAnimation:anima forKey:nil];
    self.testCAKeyframeAnimationView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 0);
}

- (void)keyFrameAnimationWithBezierPath {
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    [bezierPath moveToPoint:CGPointMake(0, 100)];
    [bezierPath addCurveToPoint:CGPointMake(kScreenWidth, 100) controlPoint1:CGPointMake(kScreenWidth/3, 0) controlPoint2:CGPointMake(kScreenWidth * 2 /3 * 2, 50)];
    
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.path = bezierPath.CGPath;
    pathLayer.fillColor = [UIColor clearColor].CGColor;
    pathLayer.strokeColor = [UIColor redColor].CGColor;
    pathLayer.lineWidth = 3.0f;
    [self.testCAKeyframeAnimationView.layer addSublayer:pathLayer];
    
    CALayer *pandaLayer = [CALayer layer];
    pandaLayer.frame = CGRectMake(0, 0, 64, 64);
    pandaLayer.position = CGPointMake(0, 150);
    pandaLayer.contents = (__bridge id)[UIImage imageNamed: @"icon_heart.png"].CGImage;
    [self.testCAKeyframeAnimationView.layer addSublayer:pandaLayer];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position";
    animation.duration = 4.0;
    animation.path = bezierPath.CGPath;
    [pandaLayer addAnimation:animation forKey:@"keyFrameAnimationWithBezierPath"];
}

#pragma mark - CAAnimationGroup

- (void)groupAnimationRotateAndScaleDownUp {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:(2 * M_PI) * 2];
    rotationAnimation.duration = 0.35f;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.toValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation.duration = 0.35f;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 0.35f;
    animationGroup.autoreverses = YES;
    animationGroup.repeatCount = 1;
    animationGroup.animations =[NSArray arrayWithObjects:rotationAnimation, scaleAnimation, nil];
    [self.testCAAnimationGroupView.layer addAnimation:animationGroup forKey:@"animationGroup"];
}

#pragma mark - UIView+Animation
/**
 UIViewAnimationOptionLayoutSubviews //提交动画的时候布局子控件，表示子控件将和父控件一同动画。
 UIViewAnimationOptionAllowUserInteraction //动画时允许用户交流，比如触摸
 UIViewAnimationOptionBeginFromCurrentState //从当前状态开始动画
 UIViewAnimationOptionRepeat //动画无限重复
 UIViewAnimationOptionAutoreverse //执行动画回路,前提是设置动画无限重复
 UIViewAnimationOptionOverrideInheritedDuration //忽略外层动画嵌套的执行时间
 UIViewAnimationOptionOverrideInheritedCurve //忽略外层动画嵌套的时间变化曲线
 UIViewAnimationOptionAllowAnimatedContent //通过改变属性和重绘实现动画效果，如果key没有提交动画将使用快照
 UIViewAnimationOptionShowHideTransitionViews //用显隐的方式替代添加移除图层的动画效果
 UIViewAnimationOptionOverrideInheritedOptions //忽略嵌套继承的选项
 
 //时间函数曲线相关
 UIViewAnimationOptionCurveEaseInOut //时间曲线函数，由慢到快
 UIViewAnimationOptionCurveEaseIn //时间曲线函数，由慢到特别快
 UIViewAnimationOptionCurveEaseOut //时间曲线函数，由快到慢
 UIViewAnimationOptionCurveLinear //时间曲线函数，匀速
 
 //转场动画相关的
 UIViewAnimationOptionTransitionNone //无转场动画
 UIViewAnimationOptionTransitionFlipFromLeft //转场从左翻转
 UIViewAnimationOptionTransitionFlipFromRight //转场从右翻转
 UIViewAnimationOptionTransitionCurlUp //上卷转场
 UIViewAnimationOptionTransitionCurlDown //下卷转场
 UIViewAnimationOptionTransitionCrossDissolve //转场交叉消失
 UIViewAnimationOptionTransitionFlipFromTop //转场从上翻转
 UIViewAnimationOptionTransitionFlipFromBottom //转场从下翻转
 */

/**
 *  UIViewAnimation
 *
 *  @brief  UIView动画应该是最简单便捷创建动画的方式了
 *
 *  @method beginAnimations:context 第一个参数用来作为动画的标识,第二个参数给代理传递消息.至于为什么一个使用
 *                                  nil而另外一个使用NULL,是因为第一个参数是一个对象指针,而第二个参数是基本数据类型.
 *  @method setAnimationCurve:      设置动画的加速或减速的方式(速度)
 *  @method setAnimationDuration:   动画持续时间
 *  @method setAnimationTransition:forView:cache:   第一个参数定义动画类型，第二个参数是当前视图对象，第三个参数是是否使用缓冲区
 *  @method commitAnimations        动画提交开始
 */

- (void)viewAnimation {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:2.0f];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.greenLabel cache:NO];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

- (void)viewAnimationWithKeyFrame {
    self.greenLabel.transform = CGAffineTransformIdentity;
    [UIView animateKeyframesWithDuration:0.5f delay:0.5f options:UIViewKeyframeAnimationOptionAutoreverse|UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        self.greenLabel.transform = CGAffineTransformMakeScale(1, 2.0);
    } completion:^(BOOL finished) {
        self.greenLabel.transform = CGAffineTransformMakeScale(1, 1.0);
    }];
}

- (void)viewAnimationWithTransition {
    [UIView transitionWithView:self.greenLabel duration:2.0f options:UIViewAnimationOptionTransitionFlipFromTop|UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse animations:^{
        self.greenLabel.backgroundColor = [UIColor redColor];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)viewAnimationWithSpring {
    self.greenLabel.frame = CGRectMake(20, 10, 50, 280);
    self.blueLabel.frame = CGRectMake(90, 10, 50, 280);
    self.yellowLabel.frame = CGRectMake(160, 10, 50, 280);
    
    [UIView animateWithDuration:2 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:130.0 options:0 animations:^{
        self.greenLabel.frame = CGRectMake(20, 70, 50, 160);
        self.blueLabel.frame = CGRectMake(90, 70, 50, 160);
        self.yellowLabel.frame = CGRectMake(160, 70, 50, 160);
    } completion:^(BOOL finished) {
        
    }];
}

@end


