//
//  NotificationService.m
//  NotificationServiceExtension
//
//  Created by 郭晓倩 on 2017/4/21.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "NotificationService.h"
#import <UIKit/UIKit.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    
//    attachments 虽然是一个数组，但是系统只会展示第一个 attachment 对象的内容。但你可以发送多个，并处理那个优先显示
//    要注意 extension 的 bundle 和 app main bundle 并不是一回事儿。你可以选择将图片资源放到 extension bundle 中，也可以选择放在 main bundle 里。总之，你需要保证能够获取到正确的，并且你具有读取权限的 url。
//    系统在创建 attachement 时会根据提供的 url 后缀确定文件类型，如果没有后缀，或者后缀无法不正确的话，你可以在创建时通过 UNNotificationAttachmentOptionsTypeHintKey 来指定资源类型。
//    你可以访问一个已经创建的 attachment 的内容，但是要注意权限问题。可以使用 startAccessingSecurityScopedResource 来暂时获取以创建的 attachment 的访问权限。
    UNNotificationAttachment* attachment = request.content.attachments.firstObject;
    if ([attachment.URL startAccessingSecurityScopedResource]) {
        
        UIImage* image = [UIImage imageWithContentsOfFile:attachment.URL.path];
        //进一步处理附件。。。
        [attachment.URL stopAccessingSecurityScopedResource];
    }

    
    //    serviceExtensionTimeWillExpire 被调用之前，你有 30 秒时间来处理和更改通知内容。
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
