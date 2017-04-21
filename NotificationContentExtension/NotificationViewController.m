//
//  NotificationViewController.m
//  NotificationContentExtension
//
//  Created by 郭晓倩 on 2017/4/21.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@property IBOutlet UILabel *label;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
}

//iOS 10 SDK 新加的另一个 Content Extension 可以用来自定义通知的详细页面的视图
//系统在接收到通知后会先查找有没有能够处理这类通知的 content extension，如果存在，那么就交给 extension 来进行处理。

//自定义 UI 的通知是和通知 category 绑定的，我们需要在 extension 的 Info.plist 里指定这个通知样式所对应的 category 标识符：
//系统在接收到通知后会先查找有没有能够处理这类通知的 content extension，如果存在，那么就交给 extension 来进行处理。

//点击通知视图 UI 本身会将我们导航到应用中，不过我们可以通过 action 的方式来对自定义 UI 进行更新。UNNotificationContentExtension 为我们提供了一个可选方法 didReceive(_:completionHandler:)，它会在用户选择了某个 action 时被调用，你有机会在这里更新通知的 UI。如果有 UI 更新，那么在方法的 completionHandler 中，开发者可以选择传递 .doNotDismiss 来保持通知继续被显示。如果没有继续显示的必要，可以选择 .dismissAndForwardAction 或者 .dismiss，前者将把通知的 action 继续传递给应用的 UNUserNotificationCenterDelegate 中的 userNotificationCenter(:didReceive:withCompletionHandler)，而后者将直接解散这个通知。
//
//如果你的自定义 UI 包含视频等，你还可以实现 UNNotificationContentExtension 里的 media 开头的一系列属性，它将为你提供一些视频播放的控件和相关方法。

- (void)didReceiveNotification:(UNNotification *)notification {
    
    NSLog(@"%s",__FUNCTION__);
    
    self.label.text = notification.request.content.body;
    
    UNNotificationAttachment* attachment = notification.request.content.attachments.firstObject;
    if ([attachment.URL startAccessingSecurityScopedResource]) {
        
        UIImage* image = [UIImage imageWithContentsOfFile:attachment.URL.path];
        
        [attachment.URL stopAccessingSecurityScopedResource];
    }
}

@end
