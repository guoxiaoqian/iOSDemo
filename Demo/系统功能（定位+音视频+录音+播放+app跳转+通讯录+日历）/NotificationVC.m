//
//  NotificationVC.m
//  Demo
//
//  Created by 郭晓倩 on 17/4/11.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "NotificationVC.h"
#import <UserNotifications/UserNotifications.h>

@interface NotificationVC ()

@end

@implementation NotificationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 本地通知


#pragma mark - 远程通知

//我们可以回顾一下整个历程和相关的主要 API：
//
//iOS 3 - 引入推送通知 UIApplication 的 registerForRemoteNotificationTypes 与 UIApplicationDelegate 的 application(_:didRegisterForRemoteNotificationsWithDeviceToken:)，application(_:didReceiveRemoteNotification:)
//iOS 4 - 引入本地通知 scheduleLocalNotification，presentLocalNotificationNow:， application(_:didReceive:)
//iOS 5 - 加入通知中心页面
//iOS 6 - 通知中心页面与 iCloud 同步
//iOS 7 - 后台静默推送 application(_:didReceiveRemoteNotification:fetchCompletionHandle:)
//iOS 8 - 重新设计 notification 权限请求，Actionable 通知 registerUserNotificationSettings(_:)，UIUserNotificationAction 与 UIUserNotificationCategory，application(_:handleActionWithIdentifier:forRemoteNotification:completionHandler:) 等
//iOS 9 - Text Input action，基于 HTTP/2 的推送请求 UIUserNotificationActionBehavior，全新的 Provider API 等
//iOS 10 中以前杂乱的和通知相关的 API 都被统一了，现在开发者可以使用独立的 UserNotifications.framework 来集中管理和使用 iOS 系统中通知的功能。在此基础上，Apple 还增加了撤回单条通知，更新已展示通知，中途修改通知内容，在通知中展示图片视频，自定义通知 UI 等一系列新功能，非常强大。

@end
