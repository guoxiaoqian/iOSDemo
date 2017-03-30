//
//  EventVC.m
//  Demo
//
//  Created by 郭晓倩 on 17/3/29.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "EventVC.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

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

//UITouch代表手指触摸，连续滑动时，UITouch对象不变，只是LocationInView变了；在Began总忽略掉Touch,后续就收不到了
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
    CGPoint previousPoint = [currentTouch preciseLocationInView:self.view];

    NSLog(@"MyGesture touchesMoved touch point %@",NSStringFromCGPoint(currentPoint));

    if (currentTouch != self.beginTouch) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    if (self.phase == MyGesturePhaseInitialPoint) {
        if (previousPoint.x > currentPoint.x && previousPoint.y > currentPoint.y) {
            //开始下画
            self.phase = MyGesturePhaseStrokeDown;
        }else{
            self.state = UIGestureRecognizerStateFailed;
        }
    }else if(self.phase == MyGesturePhaseStrokeDown) {
        if (previousPoint.x > currentPoint.x && previousPoint.y > currentPoint.y) {
            //继续下画
        }else if(previousPoint.x > currentPoint.x && previousPoint.y < currentPoint.y){
            //转折点
            self.phase = MyGesturePhaseStrokeUp;
        }else{
            self.state = UIGestureRecognizerStateFailed;
        }
    }else if(self.phase == MyGesturePhaseStrokeUp){
        if (previousPoint.x > currentPoint.x && previousPoint.y < currentPoint.y) {
            if (currentPoint.y < self.beginPoint.y){
                //比起点高，识别成功
                self.state = UIGestureRecognizerStateRecognized;
            }else{
                //继续上画
            }
        }else{
            self.state = UIGestureRecognizerStateFailed;
        }
    }else{
        self.state = UIGestureRecognizerStateFailed;
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    
    UITouch* currentTouch = [touches anyObject];
    NSLog(@"MyGesture touchesEnded touch point %@ ",NSStringFromCGPoint([currentTouch locationInView:currentTouch.view]));
    
    if (self.state != UIGestureRecognizerStateRecognized) {
        self.state = UIGestureRecognizerStateFailed;
    }
    
    self.beginTouch = nil;
    self.phase = MyGesturePhaseNotStart;
}

-(BOOL)isRightBottomWithTouch1:(UITouch*)touch1 Touch2:(UITouch*)touch2{
    CGPoint point1 = [touch1 locationInView:touch1.view];
    CGPoint point2 = [touch2 locationInView:touch2.view];
    return (point2.x - point1.x >= 0) && (point2.y - point1.y >= 0);
}

-(BOOL)isRightTopWithTouch1:(UITouch*)touch1 Touch2:(UITouch*)touch2{
    CGPoint point1 = [touch1 locationInView:touch1.view];
    CGPoint point2 = [touch2 locationInView:touch2.view];
    return (point2.x - point1.x >= 0) && (point2.y - point1.y <= 0);
}


-(BOOL)isDistanceEnoughWithTouch:(UITouch*)touch1 Touch2:(UITouch*)touch2{
    CGPoint point1 = [touch1 locationInView:touch1.view];
    CGPoint point2 = [touch2 locationInView:touch2.view];
    CGFloat distanceX = ABS(point2.x - point1.x);
    CGFloat distanceY = ABS(point2.y - point1.y);
    
    return sqrt(distanceX*distanceX + distanceY*distanceY) > 50;
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
    }
}

-(void)setCurrentTouch:(UITouch *)currentTouch{
    _currentTouch = currentTouch;
    //用了UIView的setNeedsDisplay，不会调用displayLayer，怀疑UIView有自己的一套标记
    //    [self setNeedsDisplay];
    [self.layer setNeedsDisplay];
}

@end

@interface EventVC ()

@property (strong,nonatomic) TouchView* touchView;

@end

@implementation EventVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self touchEvent];
    
    [self gesture];
    
    [self remoteControlEvent];
    
    [self motionEvent];
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
    MyGesture* gesture = [[MyGesture alloc] initWithTarget:self action:@selector(didMyGestureRecognized:)];
    [self.touchView addGestureRecognizer:gesture];
}

-(void)didMyGestureRecognized:(MyGesture*)gesture{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        NSLog(@"MyGesture Recognized !!!");
    }else if(gesture.state == UIGestureRecognizerStateFailed){
        NSLog(@"MyGesture Failed !!!");
    }
}

- (void)remoteControlEvent{
    
}

- (void)motionEvent{
    
}

@end
