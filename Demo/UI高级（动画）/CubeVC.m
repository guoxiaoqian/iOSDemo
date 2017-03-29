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

    [self rotateAngleX:-M_PI_4 angleY: -M_PI_4];
    
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
    UIButton* button = [face.subviews firstObject];
    button.layer.cornerRadius = 5;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor grayColor].CGColor;
    face.layer.transform = transform;
    face.layer.doubleSided = YES;

    [self.containerView addSubview:face];
//    CGSize containerSize = self.containerView.frame.size;
//    face.center = CGPointMake(containerSize.width/2, containerSize.height/2);
    [face mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(200);
        make.center.equalTo(self.containerView);
    }];
}

-(void)rotateAngleX:(CGFloat)angleX angleY:(CGFloat)angleY{
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0 / 500;
    perspective = CATransform3DRotate(perspective, angleX, 1, 0, 0);
    perspective = CATransform3DRotate(perspective, angleY, 0, 1, 0);
    self.containerView.layer.sublayerTransform = perspective;
    
// 最多同时显示三个面，每个对立面的userInteractionEnabled都相反
    
    ((UIView*)self.faces[0]).userInteractionEnabled = (-M_PI_2 < angleX && angleX < M_PI_2) && (-M_PI_2 < angleY && angleY < M_PI_2);
    ((UIView*)self.faces[1]).userInteractionEnabled = ! ((UIView*)self.faces[0]).userInteractionEnabled;
    
    ((UIView*)self.faces[2]).userInteractionEnabled = (-M_PI_2 < angleX && angleX < M_PI_2) && (0 < angleY && angleY < M_PI);
    ((UIView*)self.faces[3]).userInteractionEnabled = ! ((UIView*)self.faces[2]).userInteractionEnabled;
    
    ((UIView*)self.faces[4]).userInteractionEnabled = (-M_PI < angleX && angleX < 0) && (-M_PI_2 < angleY && angleY < M_PI_2);
    ((UIView*)self.faces[5]).userInteractionEnabled = ! ((UIView*)self.faces[4]).userInteractionEnabled;
    
#warning 未处理极限状态，即仅一个面在前面，其他侧面看不到（看不到的虽然userInteractionEnabled为YES，但是hitTest检测不到）
    
    for (int i = 0; i< self.faces.count; ++i) {
        UIView* face = self.faces[i];
        NSLog(@"face %d userInteractionEnabled %d",i+1,face.userInteractionEnabled);
    }
}

-(void)didPan:(UIPanGestureRecognizer*)gesture{
    //get the distance that the user’s finger has moved from the original touch location.
    CGPoint point = [gesture translationInView:self.view];
    CGFloat angleX = -point.y / kScreenHeight * (2*M_PI);
    CGFloat angleY = point.x / kScreenWidth * (2*M_PI);
    [self rotateAngleX:angleX angleY:angleY];
}

- (IBAction)didClickFace:(UIButton*)sender {
    NSLog(@"didClickFace %@",[sender titleForState:UIControlStateNormal]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
