//
//  NotificationVC.m
//  Demo
//
//  Created by 郭晓倩 on 17/4/11.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "NotificationVC.h"
#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

@interface NotificationVC ()<UNUserNotificationCenterDelegate>

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

-(IBAction)registerNotification:(id)sender{
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    
    //通用权限
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionAlert | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            NSLog(@"获取通知权限成功,然后注册远程推送或发送本地通知");
            //            [self registerRemoteNotification];
            [self sendLocalNotification];
        }else{
            NSLog(@"获取通知权限失败");
        }
    }];
}

-(void)registerRemoteNotification{
    //想APNS服务器请求Token,拿到后给自己Provider服务器
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

-(void)sendLocalNotification{
    //请求标识符可以用来区分不同的通知请求，在将一个通知请求提交后，通过特定 API 我们能够使用这个标识符来取消或者更新这个通知。我们将在稍后再提到具体用法。
    NSString* identifier = @"com.qq.student.notification";
    
    
    //内容--基本信息
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = @"标题";
    content.subtitle = @"副标题";
    content.body = @"我是bdoy";
    
    //内容--额外信息
    content.userInfo = @{@"name":@"郭晓倩"};
    
    
    //内容--操作选项
    //    iOS 8 和 9 中 Apple 引入了可以交互的通知，这是通过将一簇 action 放到一个 category 中，将这个 category 进行注册，最后在发送通知时将通知的 category 设置为要使用的 category 来实现的。
    UNNotificationAction* addAction = [UNNotificationAction actionWithIdentifier:@"action.add" title:@"add" options:UNNotificationActionOptionForeground];
    UNTextInputNotificationAction* inputAction = [UNTextInputNotificationAction actionWithIdentifier:@"action.input" title:@"input" options:UNNotificationActionOptionForeground];
    UNNotificationAction* cancelAction = [UNNotificationAction actionWithIdentifier:@"action.cancel" title:@"cancel" options:UNNotificationActionOptionDestructive];
    UNNotificationCategory* category = [UNNotificationCategory categoryWithIdentifier:@"category" actions:@[addAction,inputAction,cancelAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObject:category]];
    content.categoryIdentifier = @"category";
    //尝试展示这个通知，在下拉或者使用 3D touch 展开通知后，就可以看到对应的 action了
    //    远程推送也可以使用 category，只需要在 payload 中添加 category 字段，并指定预先定义的 category id 就可以了：
    //    {
    //        "aps":{
    //            "alert":"Please say something",
    //            "category":"saySomething"
    //        }
    //    }
    
    //内容--多媒体附件
    NSURL* fileURL = [[NSBundle mainBundle] URLForResource:@"Demo" withExtension:@"png"];
    UNNotificationAttachment* attachment = [UNNotificationAttachment attachmentWithIdentifier:@"attach" URL:fileURL options:nil error:nil];
    content.attachments = @[attachment];
    //    除了图片以外，通知还支持音频以及视频。你可以将 MP3 或者 MP4 这样的文件提供给系统来在通知中进行展示和播放。不过，这些文件都有尺寸的限制，比如图片不能超过 10MB，视频不能超过 50MB 等，
    //    远程推送中，我们在推送的 payload 中指定需要加载的图片资源地址，这个地址可以是应用 bundle 内已经存在的资源，也可以是网络的资源。
    //    Notification Service Extension 来修改推送通知内容的技术,获取或下载图片，并生成 attachment，进行通知展示；mutable-content 表示我们会在接收到通知时对内容进行更改，image 指明了目标图片的地址。
    //    {
    //        "aps":{
    //            "alert":{
    //                "title":"Image Notification",
    //                "body":"Show me an image from web!"
    //            },
    //            "mutable-content":1
    //        },
    //        "image": "https://onevcat.com/assets/images/background-cover.jpg"
    //    }
    
    
    
    
    //    触发器是只对本地通知而言的，远程推送的通知的话默认会在收到后立即显示。现在 UserNotifications 框架中提供了三种触发器，分别是：在一定时间后触发 UNTimeIntervalNotificationTrigger，在某月某日某时触发 UNCalendarNotificationTrigger 以及在用户进入或是离开某个区域时触发 UNLocationNotificationTrigger。
    UNNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:60 repeats:YES];
    
    
    
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"add notification complete, error = %@",error);
    }];

    
}

-(void)cancelOrUpdateLocalNotification{
    //    远程推送可以进行通知的更新，在使用 Provider API 向 APNs 提交请求时，在 HTTP/2 的 header 中 apns-collapse-id key 的内容将被作为该推送的标识符进行使用。多次推送同一标识符的通知即可进行更新。
    
    NSString* identifier = @"com.qq.student.notification";
    
    [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[identifier]]; //移除未展示的，取消
    
    [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[identifier]]; //删除已展示过的
    
    
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:identifier content:[UNNotificationContent new] trigger:nil];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil]; //覆盖请求，即更新
}

#pragma mark <UNUserNotificationCenterDelegate>

//如何在应用内展示通知
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSLog(@"%s title:%@",__FUNCTION__, notification.request.content.title);
    
    
    // 如果不想显示某个通知，可以直接用空 options 调用 completionHandler:
    // completionHandler(UNNotificationPresentationOptionNone)
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionAlert);
}


//收到通知响应时要如何处理的工作
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    //这个代理方法会在用户与你推送的通知进行交互时被调用，包括用户通过通知打开了你的应用，或者点击或者触发了某个 action (我们之后会提到 actionable 的通知)。因为涉及到打开应用的行为，所以实现了这个方法的 delegate 必须在 applicationDidFinishLaunching: 返回前就完成设置，
    NSLog(@"%s title:%@ userName:%@",__FUNCTION__,response.notification.request.content.title,response.notification.request.content.userInfo[@"name"]);
    
    //远程推送的 payload 内的内容也会出现在这个 userInfo 中，这样一来，不论是本地推送还是远程推送，处理的路径得到了统一。
    //    {
    //        "aps":{
    //            "alert":{
    //                "title":"I am title",
    //                "subtitle":"I am subtitle",
    //                "body":"I am body"
    //            },
    //            "sound":"default",
    //            "badge":1
    //        }
    //    }
    
    
    //根据category和action做相应的操作
    NSString* category = response.notification.request.content.categoryIdentifier;
    NSString* action = response.actionIdentifier;
    NSLog(@"category:%@ action:%@",category,action);
    if([action isEqualToString:@"action.input"]){
        NSString* input = ((UNTextInputNotificationResponse*)response).userText;
        NSLog(@"userinput:%@",input);
    }
    
    completionHandler();
}


@end

@interface AppDelegate (Notification)

@end

@implementation AppDelegate (Notification)

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"%s toke=%@",__FUNCTION__,deviceToken);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    //Code=3000 "未找到应用程序的“aps-environment”的授权字符串" 解决办法:在Capblilities中打开这个‘Push Notification’开关，steps这两步骤会自动检查APP ID等推送文件的合法性。
    NSLog(@"%s error=%@",__FUNCTION__,error);
}


-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    NSLog(@"%s",__FUNCTION__);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    //IOS10之前
    NSLog(@"%s",__FUNCTION__);
}

@end
