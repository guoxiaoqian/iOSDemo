//
//  CubeVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/3/28.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "CubeVC.h"

@interface CubeVC ()
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *faces;

@end

@implementation CubeVC

- (void)viewDidLoad {
    [super viewDidLoad];

    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0 / 500;
    //有视角后，不旋转还是看不到透视效果
    perspective = CATransform3DRotate(perspective, -M_PI_4, 1, 0, 0);
    perspective = CATransform3DRotate(perspective, -M_PI_4, 0, 1, 0);
    self.containerView.layer.sublayerTransform = perspective;
    
    //前后
    CATransform3D transform1 = CATransform3DMakeTranslation(0, 0, 100);
    [self addFaceAtIndex:0 withTransform:transform1];
    
    CATransform3D transform2 = CATransform3DMakeTranslation(0, 0, -100);
    transform2 = CATransform3DRotate(transform2, M_PI, 1, 0, 0);
    [self addFaceAtIndex:1 withTransform:transform2];
    
    //左右
    CATransform3D transform3 = CATransform3DMakeTranslation(-100, 0, 0);
    transform3 = CATransform3DRotate(transform3, -M_PI_2, 0, 1, 0);
    [self addFaceAtIndex:2 withTransform:transform3];
    
    CATransform3D transform4 = CATransform3DMakeTranslation(100, 0, 0);
    transform4 = CATransform3DRotate(transform4, M_PI_2, 0, 1, 0);
    [self addFaceAtIndex:3 withTransform:transform4];
    
    //上下
    CATransform3D transform5 = CATransform3DMakeTranslation(0, -100, 0);
    transform5 = CATransform3DRotate(transform5, M_PI_2, 1, 0, 0);
    [self addFaceAtIndex:4 withTransform:transform5];
    
    CATransform3D transform6 = CATransform3DMakeTranslation(0, 100, 0);
    transform6 = CATransform3DRotate(transform6, -M_PI_2, 1, 0, 0);
    [self addFaceAtIndex:5 withTransform:transform6];
    
    UIPanGestureRecognizer* gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [self.view addGestureRecognizer:gesture];

}

-(void)addFaceAtIndex:(NSUInteger)index withTransform:(CATransform3D)transform{
    UIView* face = [self.faces objectAtIndex:index];
    face.frame = CGRectMake(0, 0, 200, 200);
    face.layer.transform = transform;
    face.layer.doubleSided = NO;

    [self.containerView addSubview:face];
}

-(void)rotateAngleX:(CGFloat)angleX angleY:(CGFloat)angleY{
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0 / 500;
    perspective = CATransform3DRotate(perspective, angleX, 1, 0, 0);
    perspective = CATransform3DRotate(perspective, angleY, 0, 1, 0);
    self.containerView.layer.sublayerTransform = perspective;
}

-(void)didPan:(UIPanGestureRecognizer*)gesture{
    CGPoint point = [gesture translationInView:self.view];
    CGFloat angleX = -point.y / kScreenHeight * (2*M_PI);
    CGFloat angleY = point.x / kScreenWidth * (2*M_PI);
    [self rotateAngleX:angleX angleY:angleY];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
