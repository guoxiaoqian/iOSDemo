//
//  BlurEffectVC.m
//  Demo
//
//  Created by gavinxqguo on 2020/6/24.
//  Copyright © 2020 郭晓倩. All rights reserved.
//

#import "BlurEffectVC.h"

@interface BlurView : UIView

@property (strong) CAShapeLayer* shapeLayer;

@property(nonatomic, strong) UIVisualEffectView* blurView;

@end

@implementation BlurView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.shapeLayer = [CAShapeLayer layer];
        [self.layer addSublayer:self.shapeLayer];
        
        self.backgroundColor = [UIColor clearColor];
        
        UIBlurEffect* effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
        [self addSubview:self.blurView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    _shapeLayer.path = path.CGPath;
    _shapeLayer.shadowPath = path.CGPath;
    _shapeLayer.frame = self.bounds;
    _shapeLayer.fillColor = [[UIColor blackColor] colorWithAlphaComponent:0.9].CGColor;
    _shapeLayer.strokeColor = [UIColor redColor].CGColor;
    _shapeLayer.lineWidth = 3.0f;
    
    
    self.blurView.frame = self.bounds;
    CAShapeLayer* maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    self.blurView.layer.mask = maskLayer;
}

@end

@interface BlurEffectVC ()

@end

@implementation BlurEffectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor yellowColor];

    // Do any additional setup after loading the view from its nib.
    BlurView * blurView = [[BlurView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    [self.view addSubview:blurView];
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
