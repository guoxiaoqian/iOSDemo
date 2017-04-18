//
//  SystemAppVC.m
//  Demo
//
//  Created by 郭晓倩 on 17/4/11.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "SystemAppVC.h"
#import "AppDelegate.h"

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

-(void)openURL:(NSString*)urlStr{
    NSURL* url = [NSURL URLWithString:urlStr];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

-(IBAction)phoneCallByOpenURL:(id)sender{
    //不弹出提示框，直接跳转到通讯录拨打电话，通话结束返回到app
    [self openURL:@"tel://13162021017"];
}

-(IBAction)phoneCallByOpenURLWithPrompt:(id)sender{
    //弹出提示框，点击“呼叫”跳转到通讯录拨打电话，通话结束返回到app
    [self openURL:@"telprompt:13162021017"];
}

-(IBAction)phoneCallByWebview:(id)sender{
    //弹出提示框，点击“呼叫”跳转到通讯录拨打电话，通话结束返回到app
    UIWebView* callWebview = [UIWebView new];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"tel:13162021017"]]];
    [self.view addSubview:callWebview];
}

#pragma mark - 短信

-(IBAction)sendSms:(id)sender{
    NSString* phoneNumber = @"13162021017";
    NSString* url = [NSString stringWithFormat:@"sms://%@",phoneNumber];
    [self openURL:url];
}

#pragma mark - 邮件

-(IBAction)sendMail:(id)sender{
    NSString* mail = @"429267703@qq.com";
    NSString* url = [NSString stringWithFormat:@"mailto://%@",mail];
    [self openURL:url];
}

#pragma mark - 浏览器

-(IBAction)openBrowser:(id)sender{
    NSString* url = @"https://www.baidu.com";
    [self openURL:url];
}

#pragma mark - 通讯录

#pragma mark - 日历

#pragma mark - 蓝牙

#pragma mark - 社交

#pragma mark - GameCenter

#pragma mark - 应用内购买

#pragma mark - iCloud

#pragma mark - Passbook

#pragma mark - 其他跳转（系统设置）


@end

#pragma mark - 支持跳转到当前APP

//需在plist文件中添加URL types节点并配置URL Schemas作为具体协议，配置URL identifier作为这个URL的唯一标识
//然后在AppDelegate中实现跳转处理

@interface AppDelegate (Extension) <UIApplicationDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation{
    //IOS9之前
    NSLog(@"scheme:%@ host:%@",url.scheme,url.host);
    return YES;
}

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    //IOS9之后
    return YES;
}

@end

