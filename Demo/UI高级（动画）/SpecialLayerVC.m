//
//  SpecialLayerVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/4/11.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "SpecialLayerVC.h"
#import "VolumeWaveView.h"

@interface TiledView : UIView

@end

@implementation TiledView

+(Class)layerClass{
    return [CATiledLayer class];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [((CATiledLayer*)self.layer) setTileSize:CGSizeMake(100*self.contentScaleFactor, 100*self.contentScaleFactor)];
    }
    return self;
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    CGRect rect = CGContextGetClipBoundingBox(ctx);
    NSLog(@"DRAW LAYER %@",NSStringFromCGRect(rect));
    
    CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextAddRect(ctx, CGRectMake(rect.origin.x+2, rect.origin.y+2, rect.size.width-4, rect.size.height-4));
    CGContextFillPath(ctx);
}

@end


@interface SpecialLayerVC ()

@property (strong,nonatomic) CAScrollLayer* scrollLayer;

@end

@implementation SpecialLayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self shapeLayer];
    
    [self gradientLayer];
    
    [self transformLayer];
    
    [self emitterLayer];
    
    [self replicatorLayer];
    
    [self scrollLayerTest];
    
    [self tiledLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)shapeLayer{
    VolumeWaveView* waveView = [[VolumeWaveView alloc] initWithFrame:CGRectMake(0, 400, 200, 50)];
    [self.view addSubview:waveView];
    [waveView start];
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

-(void)transformLayer{
//    CATransformLayer用来创建3D的layer结构，而不是CALayer那样的扁平结构。和普通layer不同的地方有：
//    1、transform layer只渲染sublayers，那些从CALayer继承下来的属性不起作用，包括：backgroundColor, contents, border style properties, stroke style properties等。
//    2、2D图片的处理属性也不起作用，包括：filters, backgroundFilters, compositingFilter, mask, masksToBounds以及阴影属性。
//    3、opacity属性会应用到每个sublayer，transform layer并不作为一个整体来实现半透明效果。
//    4、在transform layer上不可以调用hitTest:方法，因为它并不存在一个2D的坐标空间来定位所测试的点。
//    在transform layer上设置sublayerTransform的m34值，定位一个透视点，sublayer上应用z轴位置变换的动画，就可以看到3D效果
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

-(void)replicatorLayer{
//CAReplicatorLayer创建layer和它的sublayer的多个副本，副本可以设置transform来变形，或者设置颜色、透明度的变化。
    CAReplicatorLayer* layer = [CAReplicatorLayer layer];
    layer.frame = CGRectMake(110, 110, 100, 100);
    CALayer* subLayer = [CALayer layer];
    subLayer.frame = CGRectMake(0, 0, 50, 50);
    subLayer.contents = (id)[UIImage imageNamed:@"Demo"].CGImage;
    [layer addSublayer:subLayer];
    
    layer.instanceCount = 2;
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, 0, 0, 0);
    transform = CATransform3DRotate(transform, M_PI, 1, 0, 0);//绕X轴（底边为轴），旋转后成镜像
    transform = CATransform3DScale(transform, 1, 0.8, 1);
    layer.instanceTransform = transform;
    layer.instanceRedOffset = -0.1;
    layer.instanceBlueOffset = -0.1;
    layer.instanceGreenOffset = -0.1;
    layer.instanceAlphaOffset = -0.1;
    
    [self.view.layer addSublayer:layer];
}

-(void)scrollLayerTest{

    CALayer* subLayer =[CALayer layer];
    subLayer.frame = CGRectMake(0, 0, 100, 100);
    subLayer.contents =(id)[UIImage imageNamed:@"Demo"].CGImage;

    CAScrollLayer* layer = [CAScrollLayer layer];
    layer.frame = CGRectMake(0, 0, 100, 100);
    layer.scrollMode = kCAScrollBoth;
    [layer addSublayer:subLayer];
    
    UIView* scrollView = [[UIView alloc] initWithFrame:CGRectMake(0, 220, 100, 100)];
    [scrollView.layer addSublayer:layer];
    [self.view addSubview:scrollView];
    self.scrollLayer = layer;
    
    UIPanGestureRecognizer* gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [scrollView addGestureRecognizer:gesture];
}

-(void)didPan:(UIPanGestureRecognizer*)gesture{
    CGPoint origin = self.scrollLayer.bounds.origin;
    CGPoint translation = [gesture translationInView:gesture.view];
    origin = CGPointMake(origin.x - translation.x, origin.y - translation.y);
    [self.scrollLayer scrollToPoint:origin];
    
    //重置偏移量
    [gesture setTranslation:CGPointZero inView:gesture.view];
}

-(void)tiledLayer{
    //    CATiledLayer提供异步加载图片各部分的功能。layer的drawLayer:inContext:方法会在出现时回调，用来绘制对应部分的内容。可以通过Context的clip bounds和CTM（当前图形上下文的仿射变换，CGContextGetCTM方法）来判断是图片的哪一部分以及大小。
    CGRect contentRect = CGRectMake(0, 0, 1000, 2000);
    TiledView* tiledView = [[TiledView alloc] initWithFrame:contentRect];
    
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 330, 200, 50)];
    [scrollView addSubview:tiledView];
    scrollView.contentSize = contentRect.size;
    [self.view addSubview:scrollView];
}

@end
