//
//  EventVC.m
//  Demo
//
//  Created by 郭晓倩 on 17/3/29.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "EventVC.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <CoreMotion/CoreMotion.h>

typedef enum : NSUInteger {
    MyGesturePhaseNotStart = 0,
    MyGesturePhaseInitialPoint,
    MyGesturePhaseStrokeDown,
    MyGesturePhaseStrokeUp,
} MyGesturePhase;

@interface MyGesture : UIGestureRecognizer

@property (strong,nonatomic) UITouch* beginTouch;
@property (assign,nonatomic) CGPoint beginPoint;
@property (assign,nonatomic) CGPoint turnPoint;
@property (assign,nonatomic) MyGesturePhase phase;


@end

@implementation MyGesture

//UITouch代表手指触摸，连续滑动时，UITouch对象不变，只是LocationInView变了；在Began中忽略掉Touch,后续就收不到了
//You cannot simply store references to the UITouch objects that you receive because UIKit reuses those objects and overwrites any old values. Instead, you must define custom data structures to store the touch information you need.
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    if (touches.count != 1) {
        self.state = UIGestureRecognizerStateFailed;
    }
    
    UITouch* currentTouch = [touches anyObject];
    CGPoint currentPoint = [currentTouch locationInView:self.view];
    NSLog(@"MyGesture touchesBegan touch point %@",NSStringFromCGPoint(currentPoint));
    if (self.beginTouch == nil) {
        self.beginPoint = currentPoint;
        self.beginTouch = currentTouch;
        self.phase = MyGesturePhaseInitialPoint;
    }else{
        for (UITouch* touch in touches) {
            if (touch != self.beginTouch) {
                [self ignoreTouch:touch forEvent:event];
            }
        }
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    
    UITouch* currentTouch = [touches anyObject];
    CGPoint currentPoint = [currentTouch locationInView:self.view];
    CGPoint previousPoint = [currentTouch previousLocationInView:self.view];
    
    NSLog(@"MyGesture touchesMoved touch point %@",NSStringFromCGPoint(currentPoint));
    
    if (currentTouch != self.beginTouch) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    if (self.phase == MyGesturePhaseInitialPoint) {
        if (currentPoint.x >= self.beginPoint.x && currentPoint.y >= self.beginPoint.y) {
            //开始下画
            self.phase = MyGesturePhaseStrokeDown;
        }else{
            self.state = UIGestureRecognizerStateFailed;
        }
    }else if(self.phase == MyGesturePhaseStrokeDown) {
        if (currentPoint.x >= previousPoint.x) {
            if (currentPoint.y < previousPoint.y) {
                //转折点
                self.phase = MyGesturePhaseStrokeUp;
            }else{
                //继续下画
            }
        }else{
            self.state = UIGestureRecognizerStateFailed;
        }
    }else if(self.phase == MyGesturePhaseStrokeUp){
        if (currentPoint.x < previousPoint.x || currentPoint.y > previousPoint.y) {
            self.state = UIGestureRecognizerStateFailed;
        }
    }else{
        self.state = UIGestureRecognizerStateFailed;
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    
    UITouch* currentTouch = [touches anyObject];
    CGPoint currentPoint = [currentTouch locationInView:self.view];
    NSLog(@"MyGesture touchesEnded touch point %@ ",NSStringFromCGPoint(currentPoint));
    
    if (currentTouch != self.beginTouch) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    
    if (self.state == UIGestureRecognizerStatePossible && self.phase == MyGesturePhaseStrokeUp && currentPoint.y < self.beginPoint.y) {
        self.state = UIGestureRecognizerStateRecognized;
#warning 手势识别后不再调用UIView的touchesEnded
        [self.view touchesEnded:touches withEvent:event];
    }else{
        self.state = UIGestureRecognizerStateFailed;
    }
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    
    [self resetPrivate];
    
    self.state = UIGestureRecognizerStateCancelled;
}

//override, called by recognized or failed
-(void)reset{
    [super reset];
    
    [self resetPrivate];
}

-(void)setState:(UIGestureRecognizerState)state{
    [super setState:state];
}

-(void)resetPrivate{
    self.beginTouch = nil;
    self.beginPoint = CGPointZero;
    self.phase = MyGesturePhaseNotStart;
}

@end



@interface TouchView : UIView

@property (strong,nonatomic) UIBezierPath* path;
@property (strong,nonatomic) UITouch* currentTouch;
@end

@implementation TouchView

+(Class)layerClass{
    return [CAShapeLayer class];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.layer.needsDisplayOnBoundsChange = YES;
        CAShapeLayer* shapeLayer = (CAShapeLayer*)self.layer;
        shapeLayer.strokeColor = [UIColor blackColor].CGColor;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.backgroundColor = [UIColor yellowColor].CGColor;
        shapeLayer.lineWidth = 5;
        shapeLayer.lineCap = kCALineCapRound;
        //可以把ShapeLayer超界部分的裁剪
        self.clipsToBounds = YES;
    }
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.currentTouch = [touches anyObject];
    NSLog(@"TouchView touchesBegan touch point %@ ",NSStringFromCGPoint([self.currentTouch locationInView:self]));
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.currentTouch = [touches anyObject];
    NSLog(@"TouchView touchesMoved touch point %@ ",NSStringFromCGPoint([self.currentTouch locationInView:self]));
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.currentTouch = [touches anyObject];
    NSLog(@"TouchView touchesEnded touch point %@ ",NSStringFromCGPoint([self.currentTouch locationInView:self]));
    
    //清空数据，结束划线
    _path = nil;
    self.currentTouch = nil;
}



//display-->delegate:displayLayer-->delegate:drawLayer:inContext:-->drawInContext-->drawRect
-(void)displayLayer:(CALayer *)layer{
    if (_currentTouch) {
        if (_path == nil) {
            _path = [UIBezierPath bezierPath];
            [_path moveToPoint:[_currentTouch locationInView:self]];
        }
        [_path addLineToPoint:[_currentTouch locationInView:self]];
    }
    
    if (_path) {
        ((CAShapeLayer*)self.layer).path = _path.CGPath;
    }else{
        ((CAShapeLayer*)self.layer).path = NULL;
    }
}

-(void)setCurrentTouch:(UITouch *)currentTouch{
    _currentTouch = currentTouch;
    //用了UIView的setNeedsDisplay，不会调用displayLayer，怀疑UIView有自己的一套标记
    //    [self setNeedsDisplay];
    [self.layer setNeedsDisplay];
}

@end

@interface EventVC () <UIGestureRecognizerDelegate>

@property (strong,nonatomic) TouchView* touchView;
@property (strong,nonatomic) MyGesture* myGesture;
@property (strong,nonatomic) UISwipeGestureRecognizer* swipeGesture;

@property (strong,nonatomic) CMMotionManager* motionManager;

@end

@implementation EventVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self touchEvent];
    
    [self gesture];
    
    [self coreMotion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchEvent{
    self.touchView = [[TouchView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 300)];
    [self.view addSubview:self.touchView];
}

- (void)gesture{
    self.myGesture = [[MyGesture alloc] initWithTarget:self action:@selector(didMyGestureRecognized:)];
    self.myGesture.delegate = self;
    [self.touchView addGestureRecognizer:self.myGesture];
    
    self.swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeGestureRecognized:)];
    self.swipeGesture.delegate = self;
    [self.touchView addGestureRecognizer:self.swipeGesture];
}

#pragma mark UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    //手势依赖顺序
    if (gestureRecognizer == self.myGesture && otherGestureRecognizer == self.swipeGesture) {
        return YES;
    }
    return NO;
}

#pragma mark Gesture Action

-(void)didMyGestureRecognized:(MyGesture*)gesture{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        NSLog(@"MyGesture Recognized !!!");
    }
}

-(void)didSwipeGestureRecognized:(UISwipeGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        NSLog(@"UISwipeGestureRecognizer Recognized !!! direction:%ld",gesture.direction);
    }
}



#pragma mark - Motion Event - Orientation

-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //接受MotionEvent-Shake
    [self becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didOrentationChaged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

-(void)didOrentationChaged:(NSNotification*)noti{
    __unused UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
}

#pragma mark - Motion Event - Shake

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    NSLog(@"motion begin %ld",motion);
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"shake !!!!");
    }
}

-(void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    NSLog(@"motion canceled %ld",motion);
}

#pragma mark - Motion Event - CoreMotion

//https://developer.apple.com/library/content/documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/HandlingProcessedDeviceMotionData.html#//apple_ref/doc/uid/TP40009541-CH27-SW1

//The device-motion service offers a simple way for you to get motion-related data for your app. Raw accelerometer and gyroscope data needs to be processed to remove bias from other factors, such as gravity. The device-motion service does this processing for you, giving you refined data that you can use right away.

//The device-motion service uses the available hardware to generate a CMDeviceMotion object, which contains the following information:
//
//The device’s orientation (or attitude) in three-dimensional space relative to a reference frame（三维朝向）
//The unbiased rotation rate (旋转角速度)
//The current gravity vector
//The user-generated acceleration vector (without gravity) (加速度)
//The current magnetic field vector （磁感应方向）

-(void)coreMotion{
    self.motionManager = [[CMMotionManager alloc] init];
    if (self.motionManager.isDeviceMotionAvailable) {
        self.motionManager.deviceMotionUpdateInterval = 1.0 / 60;
        self.motionManager.showsDeviceMovementDisplay = YES;
        //        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        //            if (motion) {
        //                CMAttitude *attitude = motion.attitude;
        //                CMRotationRate rotationRate = motion.rotationRate;
        //                CMAcceleration userAcceleration = motion.userAcceleration;
        //                CMCalibratedMagneticField magneticField = motion.magneticField;
        //            }
        //        }];
        
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical toQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            if (motion) {
                CMAttitude *attitude = motion.attitude;
                CMRotationRate rotationRate = motion.rotationRate;
                CMAcceleration userAcceleration = motion.userAcceleration;
                CMCalibratedMagneticField magneticField = motion.magneticField;
            }
        }];
        
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.motionManager.isDeviceMotionActive) {
            [self.motionManager stopDeviceMotionUpdates];
        }
    });
}

@end
