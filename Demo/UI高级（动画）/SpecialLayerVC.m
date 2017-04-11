//
//  SpecialLayerVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/4/11.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "SpecialLayerVC.h"

@interface SpecialLayerVC ()

@end

@implementation SpecialLayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self gradientLayer];
    
    [self transformLayer];
    
    [self emitterLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)gradientLayer{
    CAGradientLayer* layer = [CAGradientLayer layer];
    layer.frame = CGRectMake(0, 0, 100, 100);
    layer.colors = @[(__bridge id)[UIColor blueColor].CGColor,
                     (__bridge id)[UIColor redColor].CGColor,
                     (__bridge id)[UIColor yellowColor].CGColor];
    layer.locations = @[@(0),@(0.5),@(1)];
    layer.startPoint = CGPointMake(0, 0); //左上角
    layer.endPoint = CGPointMake(1, 1); //右下角
    [self.view.layer addSublayer:layer];
}

-(void)transformLayer{ //zPosition是三维的
    CATransformLayer* layer = [CATransformLayer layer];
    layer.frame = CGRectMake(110, 0, 100, 100);
    
    [layer addSublayer:[self transformLayerWithColor:[UIColor redColor] zPosition:20]];
    [layer addSublayer:[self transformLayerWithColor:[UIColor blueColor] zPosition:60]];
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = - 1.0 / 100;
    layer.transform = CATransform3DRotate(transform, M_PI_4, 0, 1, 0);
    
    [self.view.layer addSublayer:layer];
}

-(CALayer*)transformLayerWithColor:(UIColor*)color zPosition:(CGFloat)zPosition{
    CALayer* layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 100, 100);
    layer.backgroundColor = color.CGColor;
    layer.zPosition = zPosition;
    layer.opacity = 0.5;
    return layer;
}

-(void)emitterLayer{
//    CAEmitterLayer用来实现基于Core Animation的粒子发生器系统。每个粒子都是一个CAEmitterCell的实例。粒子绘制在背景色与border之上。
//    在属性中，可以指定Layer中的CAEmitterCell数组，每个cell定义了自己的一组属性，如速度、粒子发生率、旋转、缩放或者内容等。每个粒子也都有一个emitterCells属性，可以做为一个粒子发生器来运作。Layer还可以设置发生器位置、发生器形状、发射单元的位置等等。

    CAEmitterLayer* layer = [CAEmitterLayer layer];
    layer.frame = CGRectMake(0, 110, 100, 100);
    layer.emitterPosition = CGPointMake(50, 50);
    layer.renderMode = kCAEmitterLayerAdditive;
    layer.birthRate = 1;
    
    CAEmitterCell* item = [CAEmitterCell emitterCell];
    item.birthRate = 20; //最终生成速度要与layer的birthRate相乘
    item.velocity = 400;
    item.velocityRange = 100; //速度浮动范围，300-500
    item.yAcceleration = 250; //用于粒子减速
    item.lifetime = 1.6;
    item.contents = (id)[UIImage imageNamed:@"Demo"].CGImage;
//    emissionLongitude和emissionLatitude指定了经纬度，经度角代表了x-y轴平面上与x轴之间的夹角，纬度角代表了x-z轴平面上与x轴之间的夹角。emissionRange设置了一个范围，围绕着y轴负方向，建立了一个圆锥形，粒子从这个圆锥形的范围内打出。
    item.emissionLatitude = 0;
    item.emissionLongitude = -M_PI_2;
    item.emissionRange = M_PI_4;
    item.color = CGColorCreateCopy([UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5].CGColor);
    //设置了每个色值的浮动范围，
    item.redRange = 0.5;
    item.greenRange = 0.5;
    item.blueRange = 0.5;
    
    layer.emitterCells = @[item];
    
    [self.view.layer addSublayer:layer];
}

@end
