//
//  TodayViewController.m
//  TodayExtension
//
//  Created by 郭晓倩 on 17/4/21.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <Foundation/Foundation.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//扩展 (Extension) 是 iOS 8 和 OSX 10.10 加入的一个非常大的功能点，开发者可以通过系统提供给我们的扩展接入点 (Extension point) 来为系统特定的服务提供某些附加的功能。对于 iOS 来说，可以使用的扩展接入点有以下几个：
//Today 扩展 - 在下拉的通知中心的 “今天” 的面板中添加一个 widget
//分享扩展 - 点击分享按钮后将网站或者照片通过应用分享
//动作扩展 - 点击 Action 按钮后通过判断上下文来将内容发送到应用
//照片编辑扩展 - 在系统的照片应用中提供照片编辑的能力
//文档提供扩展 - 提供和管理文件内容
//自定义键盘 - 提供一个可以用在所有应用的替代系统键盘的自定义键盘或输入法

//应用扩展与应用不同，它是主体应用程序（containing app）中一个单独的包，并能生成单独的二进制文件（xxx.appex）。
//一个应用允许多个扩展，意义着会有多个appex文件。
//在应用打包时，会自动包含应用扩展。
//用户在app story安装应用时，应用扩展也会被安装。
//但是，大部分扩展都需要用户自行启用它。如通知中心的扩展需要在通知中心中启用，开发者们应该在应用内对用户进行指引操作

//一个扩展并不是一个app，它的生命周期和运行环境不同于普通app。在生命周期方面，扩展的生命周期从用户在另一个app中选择了扩展开始(Today中添加Widget，分享中点击一项)，一直到扩展完成了用户的请求生命周期结束。
//扩展是一个单独的个体。扩展拥有独立的target，独立的bundle文件，独立的运行进程，独立的地址空间。


//调用扩展的应用称为hostapp，对于Widget扩展，host app就是Today。host app会在扩展的有效生命周期内定义一个扩展上下文。通过扩展上下文，hostapp可以和扩展互传数据。注意，扩展只和host app直接通信，扩展与containg app以及containing app与hostapp之间不存在通信关系，如果扩展需要打开containg app，则通过自定义URL scheme方式实现，而不是直接向containgapp发送消息。

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    //在iOS8中，UIViewController新增了一个扩展上下文属性extensionContext，来处理containingapp与扩展之间的通信
    //通过openURL方式拉起主应用
    [self.extensionContext openURL:[NSURL URLWithString:@""] completionHandler:nil];

    completionHandler(NCUpdateResultNewData);
}

@end
