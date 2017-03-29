//
//  EventVC.m
//  Demo
//
//  Created by 郭晓倩 on 17/3/29.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "EventVC.h"

@interface MyGesture : UIGestureRecognizer

@end

@implementation MyGesture


@end



@interface TouchView : UIView

@property (strong,nonatomic) CAShapeLayer* shapeLayer;
@property (strong,nonatomic) UIBezierPath* path;
@property (strong,nonatomic) UITouch* currentTouch;
@end

@implementation TouchView

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.currentTouch = [touches anyObject];
    NSLog(@"TouchView touchesBegan touch point %@ ",NSStringFromCGPoint([self.currentTouch locationInView:self]));
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.currentTouch = [touches anyObject];
    NSLog(@"TouchView touchesMoved touch point %@ ",NSStringFromCGPoint([self.currentTouch locationInView:self]));
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    self.currentTouch = [touches anyObject];
    NSLog(@"TouchView touchesEnded touch point %@ ",NSStringFromCGPoint([self.currentTouch locationInView:self]));
    
    _currentTouch = nil;
    _path = nil;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect{
    if (_shapeLayer == nil) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.frame = self.layer.bounds;
        _shapeLayer.backgroundColor = [UIColor yellowColor].CGColor;
        _shapeLayer.strokeColor = [UIColor blackColor].CGColor;
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        _shapeLayer.lineWidth = 5;
        _shapeLayer.lineCap = kCALineCapRound;
        [self.layer addSublayer:_shapeLayer];
    }
    
    if (_currentTouch) {
        if (_path == nil) {
            _path = [UIBezierPath bezierPath];
            [_path moveToPoint:[_currentTouch locationInView:self]];
        }
        [_path addLineToPoint:[_currentTouch locationInView:self]];
    }
    
    if (_path) {
        _shapeLayer.path = _path.CGPath;
    }
}

-(void)setCurrentTouch:(UITouch *)currentTouch{
    _currentTouch = currentTouch;
    [self setNeedsDisplay];
}

@end

@interface EventVC ()

@end

@implementation EventVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self touchEvent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchEvent{
    TouchView* view = [[TouchView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 300)];
    [self.view addSubview:view];
}

- (void)gesture{

}

- (void)remoteControlEvent{

}

- (void)motionEvent{

}

@end
