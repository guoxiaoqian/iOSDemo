//
//  PresentVC.m
//  Demo
//
//  Created by gavinxqguo on 2020/9/16.
//  Copyright © 2020 郭晓倩. All rights reserved.
//

#import "PresentVC.h"

@interface PresentVC ()

@end

@implementation PresentVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    UIButton* presentBtn1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [presentBtn1 setTitle:@"弹屏1" forState:UIControlStateNormal];
    presentBtn1.frame = CGRectMake(100, 100, 100, 50);
    [presentBtn1 addTarget:self action:@selector(clickPresentBtn1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:presentBtn1];
    
    UIButton* presentBtn2 = [UIButton buttonWithType:UIButtonTypeSystem];
     [presentBtn2 setTitle:@"弹屏1" forState:UIControlStateNormal];
     presentBtn2.frame = CGRectMake(100, 200, 100, 50);
     [presentBtn2 addTarget:self action:@selector(clickPresentBtn2) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:presentBtn2];
}

- (UIViewController*)viewControllerWithColor:(UIColor*)color {
    UIViewController* vc = [UIViewController new];
    vc.view.backgroundColor = color;
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickChildVC)];
    [vc.view addGestureRecognizer:gesture];
    return vc;
}

- (void)clickPresentBtn1 {
    UIViewController* vc = [self viewControllerWithColor:[UIColor yellowColor]];
    vc.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)clickPresentBtn2 {
    UIViewController* vc = [self viewControllerWithColor:[UIColor blueColor]];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)didClickChildVC {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
