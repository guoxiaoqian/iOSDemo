//
//  VolumeWaveView.m
//  全靠浪
//
//  Created by 郭晓倩 on 17/4/15.
//  Copyright © 2017年 QQingiOSTeam. All rights reserved.
//

#import "VolumeWaveView.h"


@interface VolumeWaveView ()

@property (strong,nonatomic) CADisplayLink* displayLink;
@property (assign,nonatomic) CGFloat offsetX;

@end

@implementation VolumeWaveView

+(Class)layerClass{
    return [CAShapeLayer class];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        CAShapeLayer* shapeLayer = (CAShapeLayer*)self.layer;
        shapeLayer.strokeColor = [UIColor redColor].CGColor;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    }
    return self;
}


#pragma mark - Public


- (void)start {
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(didDisplayLinkCome)];
    }
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stop {
    [_displayLink invalidate];
    _displayLink = nil;
    
    //清理视图
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CAShapeLayer* shapeLayer = (CAShapeLayer*)self.layer;
        shapeLayer.path = NULL;
        self.offsetX = 0;
    });
}

#pragma mark - Private

- (void)didDisplayLinkCome {
    static CGFloat speed = 3;
    static CGFloat periodWidth = 100;
    
    CAShapeLayer* shapeLayer = (CAShapeLayer*)self.layer;
    self.offsetX += speed;
    CGPathRef path = [self pathWithWaveFrame:self.bounds periodWidth:periodWidth offsetX:self.offsetX];
    shapeLayer.path = path;
    CGPathRelease(path);
}

- (CGMutablePathRef)pathWithWaveFrame:(CGRect)waveFrame
                          periodWidth:(float)periodWidth
                              offsetX:(float)offsetX {
    //声明第一条波曲线的路径
    CGMutablePathRef path = CGPathCreateMutable();
    
    BOOL firstPoint = YES;
    CGFloat y = 0.f;
    //第一个波纹的公式
    for (float x = waveFrame.origin.x; x <= waveFrame.origin.x + waveFrame.size.width ; x++) {
        y = (waveFrame.size.height/2) * sin(x/periodWidth * 2* M_PI - offsetX/periodWidth * 2* M_PI) + waveFrame.origin.y + waveFrame.size.height/2 ;
        if (firstPoint) {
            CGPathMoveToPoint(path, nil, x, y);
            firstPoint = NO;
        } else {
            CGPathAddLineToPoint(path, nil, x, y);
        }
        x++;
    }
    
    return path;
}

@end


