//
//  AutoLayoutVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/4/27.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "AutoLayoutVC.h"

@interface AutoLayoutVC ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *innerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollContentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollContentInnerViewHeightConstraint;

@end

@implementation AutoLayoutVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
}

- (IBAction)didClickChangeInnerViewHeight:(id)sender {
    if (self.innerViewHeightConstraint.constant == 10) {
        self.innerViewHeightConstraint.constant = 100;
    }else{
        self.innerViewHeightConstraint.constant = 10;
    }
    //约束修改时，触发冲突检查，不会进行真正的布局;除了强制布局layoutIfNeeded,其余则Runloop周期末尾布局
    self.outerViewHeightConstraint.constant = self.innerViewHeightConstraint.constant + 2*10;
}

- (IBAction)didClickChangeScrollContentViewHeight:(id)sender {
    if (self.scrollContentViewHeightConstraint.constant == 10) {
        self.scrollContentViewHeightConstraint.constant = 600;
    }else{
        self.scrollContentViewHeightConstraint.constant = 10;
    }
    //content高度变了，会自动调整scrollContentSize
}


- (IBAction)didClickChangeScrollContentInnerViewHeight:(id)sender {
    [self.scrollContentView removeConstraint:self.scrollContentViewHeightConstraint];
    if (self.scrollContentInnerViewHeightConstraint.constant == 10) {
        self.scrollContentInnerViewHeightConstraint.constant = 600;
    }else{
        self.scrollContentInnerViewHeightConstraint.constant = 10;
    }
}

@end
