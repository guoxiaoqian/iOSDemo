//
//  Quartz2DVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/3/19.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "Quartz2DVC.h"


@interface Quartz2DView : UIView

@end

@implementation Quartz2DView

-(void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //先Transform再绘制才有效果
//    [self drawTransform:context];

    
    [self drawBasicShape:context];
    
    [self drawBezierPath:context];
    
    [self clipImage];
    
    
}

-(void)drawBasicShape:(CGContextRef)context{
    //****Context属性
//    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    [[UIColor redColor] setStroke];
//    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    [[UIColor blueColor] setFill];
    CGContextSetLineWidth(context, 2);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    //****划线
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 100, 100);
    CGContextAddRect(context, CGRectMake(0, 0, 100, 100));
    CGContextStrokePath(context);

    //stroke和fill会隐式close,如果要同时stroke和fill，必须使用CGContextDrawPath
    
    //****画圆
    CGContextAddArc(context, 100, 100, 50, 0, 2*M_PI, 1);
    CGContextFillPath(context);
    
    CGContextAddEllipseInRect(context, CGRectMake(110, 0, 100, 50));
    CGContextStrokePath(context);
    
    //***虚线
    CGContextSaveGState(context);
    CGFloat pattern[] = {10,5};
    CGContextSetLineDash(context, 0,pattern, 2);
    CGContextMoveToPoint(context, 0, 50);
    CGContextAddLineToPoint(context, 100, 50);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    //***贝塞尔
    CGContextMoveToPoint(context, 0, 50);
    CGContextAddCurveToPoint(context, 25, 100, 75, 0, 100, 50);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, 0, 100);
    CGContextAddQuadCurveToPoint(context, 25, 150, 50, 100);
    CGContextStrokePath(context);
}

-(void)drawBezierPath:(CGContextRef)context{
    UIBezierPath* path = [UIBezierPath bezierPath];
    path.lineWidth = 3;
    [path moveToPoint:CGPointMake(200, 0)];
    [path addLineToPoint:CGPointMake(200, 100)];
    [path stroke];
    
    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(200, 0, 50, 100)];
    [path fill];
    
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(200, 0, 50, 100) cornerRadius:5];
    [path stroke];
    
    [[UIColor yellowColor] setStroke];
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(200, 80, 50, 100) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
    [path stroke];
    
    path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(200, 100) radius:50 startAngle:0 endAngle:M_PI clockwise:YES];
    [path stroke];

}

-(void)drawTransform:(CGContextRef)context{
//    CGContextTranslateCTM(context, 100, 100);
    CGContextScaleCTM(context, 2, 2);
//    CGContextRotateCTM(context, M_PI_2);
}

-(void)clipImage{
    UIImage* image = [UIImage imageNamed:@"Demo"];
    UIBezierPath* path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    [path addClip];
    [image drawAtPoint:CGPointZero];
}

-(UIImage*)captureView{
    UIGraphicsBeginImageContext(CGSizeMake(200, 200));
     CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

@interface Quartz2DVC ()

@end

@implementation Quartz2DVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // Do any additional setup after loading the view from its nib.
    Quartz2DView* testView = [[Quartz2DView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    testView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:testView];
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 400, 100, 100)];
    [self.view addSubview:imageView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIImage* image = [testView captureView];
        imageView.image = image;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
