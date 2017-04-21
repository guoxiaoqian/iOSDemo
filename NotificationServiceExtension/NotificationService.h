//
//  NotificationService.h
//  NotificationServiceExtension
//
//  Created by 郭晓倩 on 2017/4/21.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>


//扩展 (Extension) 是 iOS 8 和 OSX 10.10 加入的一个非常大的功能点，开发者可以通过系统提供给我们的扩展接入点 (Extension point) 来为系统特定的服务提供某些附加的功能。对于 iOS 来说，可以使用的扩展接入点有以下几个：
//
//Today 扩展 - 在下拉的通知中心的 “今天” 的面板中添加一个 widget
//分享扩展 - 点击分享按钮后将网站或者照片通过应用分享
//动作扩展 - 点击 Action 按钮后通过判断上下文来将内容发送到应用
//照片编辑扩展 - 在系统的照片应用中提供照片编辑的能力
//文档提供扩展 - 提供和管理文件内容
//自定义键盘 - 提供一个可以用在所有应用的替代系统键盘的自定义键盘或输入法


//而扩展在 iOS 中是不能以单独的形式存在的，也就是说我们不能直接在 AppStore 提供一个扩展的下载，扩展一定是随着一个应用一起打包提供的。用户在安装了带有扩展的应用后，将可以在通知中心的今日界面中，或者是系统的设置中来选择开启还是关闭你的扩展。而对于开发者来说，提供扩展的方式是在 app 的项目中加入相应的扩展的 target。


//因为扩展其实是依赖于调用其的宿主 app 的，因此其生命周期也是由用户在宿主 app 中的行为所决定的。一般来说，用户在宿主 app 中触发了该扩展后，扩展的生命周期就开始了：比如在分享选项中选择了你的扩展，或者向通知中心中添加了你的 widget 等等。而所有的扩展都是由 ViewController 进行定义的，在用户决定使用某个扩展时，其对应的 ViewController 就会被加载，因此你可以像在编写传统 app 的 ViewController 那样获取到诸如 viewDidLoad 这样的方法，并进行界面构建及做相应的逻辑。扩展应该保持功能的单一专注，并且迅速处理任务，在执行完成必要的任务，或者是在后台预约完成任务后，一般需要尽快通过回调将控制权交回给宿主 app，至此生命周期结束。


//扩展和容器应用的交互
//扩展和容器应用本身并不共享一个进程，但是作为扩展，其实是主体应用功能的延伸，肯定不可避免地需要使用到应用本身的逻辑甚至界面。在这种情况下，我们可以使用 iOS 8 新引入的自制 framework 的方式来组织需要重用的代码，这样在链接 framework 后 app 和扩展就都能使用相同的代码了。
//
//另一个常见需求就是数据共享，即扩展和应用互相希望访问对方的数据。这可以通过开启 App Groups 和进行相应的配置来开启在两个进程间的数据共享。这包括了使用 ` NSUserDefaults 进行小数据的共享，或者使用 NSFileCoordinator 和 NSFilePresenter` 甚至是 CoreData 和 SQLite 来进行更大的文件或者是更复杂的数据交互。
//
//另外，一直以来的自定义的 url scheme 也是从扩展向应用反馈数据和交互的渠道之一。

@interface NotificationService : UNNotificationServiceExtension

@end
