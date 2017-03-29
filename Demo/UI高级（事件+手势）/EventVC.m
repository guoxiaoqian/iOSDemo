//
//  EventVC.m
//  Demo
//
//  Created by 郭晓倩 on 17/3/29.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "EventVC.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface MyGesture : UIGestureRecognizer

@property (strong,nonatomic) UITouch* beginTouch;
@property (strong,nonatomic) UITouch* turnTouch;


@end

@implementation MyGesture

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch* currentTouch = [touches anyObject];
    NSLog(@"MyGesture touchesBegan touch point %@  \n %@",NSStringFromCGPoint([currentTouch locationInView:currentTouch.view]),currentTouch);
    self.state = UIGestureRecognizerStateBegan;
    self.beginTouch = currentTouch;
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch* currentTouch = [touches anyObject];
    NSLog(@"MyGesture touchesMoved touch point %@ \n %@",NSStringFromCGPoint([currentTouch locationInView:currentTouch.view]),currentTouch);
    if (self.turnTouch == nil) {
        if ([self isRightBottomWithTouch1:self.beginTouch Touch2:currentTouch]) {
            if ([self isDistanceEnoughWithTouch:self.beginTouch Touch2:currentTouch]) {
                self.turnTouch = currentTouch;
            }
            self.state = UIGestureRecognizerStateChanged;
        }else{
            self.state = UIGestureRecognizerStateFailed;
        }
    }else{
        if ([self isRightBottomWithTouch1:self.beginTouch Touch2:currentTouch]) {
            self.turnTouch = currentTouch;
            self.state = UIGestureRecognizerStateChanged;
        }else{
            if ([self isRightTopWithTouch1:self.turnTouch Touch2:currentTouch]) {
                if ([self isDistanceEnoughWithTouch:self.turnTouch Touch2:currentTouch]) {
                    self.state = UIGestureRecognizerStateRecognized;
                }else{
                    self.state = UIGestureRecognizerStateChanged;
                }
            }else{
                self.state = UIGestureRecognizerStateChanged;
            }
        }
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch* currentTouch = [touches anyObject];
    NSLog(@"MyGesture touchesEnded touch point %@ ",NSStringFromCGPoint([currentTouch locationInView:currentTouch.view]));
    if (self.state != UIGestureRecognizerStateRecognized) {
        self.state = UIGestureRecognizerStateFailed;
    }

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
