//
//  SystemAppVC.m
//  Demo
//
//  Created by 郭晓倩 on 17/4/11.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "SystemAppVC.h"

@interface SystemAppVC ()

@end

@implementation SystemAppVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 打电话

//tel:或者tel://、telprompt:或telprompt://(拨打电话前有提示)

#warning 崩溃
-(IBAction)phoneCallByOpenURL:(id)sender{
    //不弹出提示框，直接跳转到通讯录拨打电话，通话结束返回到app
    [[UIApplication sharedApplication] openURL:@"tel://13162021017"];
}

-(IBAction)phoneCallByOpenURLWithPrompt:(id)sender{
    //弹出提示框，点击“呼叫”跳转到通讯录拨打电话，通话结束返回到app
    [[UIApplication sharedApplication] openURL:@"telprompt:13162021017"];
}

-(IBAction)phoneCallByWebview:(id)sender{
    //弹出提示框，点击“呼叫”跳转到通讯录拨打电话，通话结束返回到app
    UIWebView* callWebview = [UIWebView new];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"tel:13162021017"]]];
    [self.view addSubview:callWebview];
}

#pragma mark - 短信

#pragma mark - 邮件

#pragma mark - 浏览器

#pragma mark - 通讯录

#pragma mark - 日历

#pragma mark - 蓝牙

#pragma mark - 社交

#pragma mark - GameCenter

#pragma mark - 应用内购买

#pragma mark - iCloud

#pragma mark - Passbook

#pragma mark - 其他跳转（系统设置）

#pragma mark - 支持跳转到当前APP

@end
