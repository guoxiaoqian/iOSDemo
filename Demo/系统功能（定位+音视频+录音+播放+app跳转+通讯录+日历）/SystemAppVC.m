//
//  SystemAppVC.m
//  Demo
//
//  Created by 郭晓倩 on 17/4/11.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "SystemAppVC.h"
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import <EventKit/EventKit.h>

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import <Social/Social.h>

#import <iAd/iAd.h>

@interface SystemAppVC () <MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,MCSessionDelegate,MCBrowserViewControllerDelegate,ADBannerViewDelegate>

@property (assign,nonatomic) ABAddressBookRef addressBook;//通讯录
@property (strong,nonatomic) NSMutableArray *allPerson;//通讯录所有人员

@property (strong,nonatomic) MCAdvertiserAssistant* advertiserAssistant;
@property (strong,nonatomic) MCSession* advertiserSession;
@property (weak, nonatomic) IBOutlet UIImageView *receiveImageView;

@property (strong,nonatomic) MCBrowserViewController* browerVC;
@property (strong,nonatomic) MCSession* browserSession;


@property (weak, nonatomic) IBOutlet ADBannerView *adBannerView;

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

//如果想要在应用程序内部完成这些操作则可以利用iOS中的MessageUI.framework,它提供了关于短信和邮件的UI接口供开发者在应用程序内部调用。

-(IBAction)sendMessageInApp:(id)sender{
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController* messageVC = [[MFMessageComposeViewController alloc] init];
        messageVC.messageComposeDelegate = self;
        messageVC.body = @"内容";
        messageVC.recipients = @[@"13162021017"];
        if ([MFMessageComposeViewController canSendSubject]) {
            messageVC.subject = @"主题";
        }
        if ([MFMessageComposeViewController canSendAttachments]){
            NSString* fileName = @"Demo.png";
            NSString* filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
            NSURL* fileURL = [NSURL fileURLWithPath:filePath];
            
            [messageVC addAttachmentURL:fileURL withAlternateFilename:fileName];
            
            //uti:统一类型标识，标识具体文件类型，详情查看：帮助文档中System-Declared Uniform Type Identifiers
            [messageVC addAttachmentData:[NSData dataWithContentsOfURL:fileURL] typeIdentifier:@"public.image" filename:fileName];
        }
        
        [self presentViewController:messageVC animated:YES completion:^{
            
        }];
    }
}

#pragma mark MFMessageComposeViewControllerDelegate

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"短信发送取消");
            break;
        case MessageComposeResultFailed:
            NSLog(@"短信发送失败");
            break;
        case MessageComposeResultSent:
            NSLog(@"短信发送成功");
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - 邮件


-(IBAction)sendMail:(id)sender{
    NSString* mail = @"429267703@qq.com";
    NSString* url = [NSString stringWithFormat:@"mailto://%@",mail];
    [self openURL:url];
}

-(IBAction)sendEmailInApp:(id)sender{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* mailVC = [[MFMailComposeViewController alloc] init];
        mailVC.mailComposeDelegate = self;
        [mailVC setTitle:@"标题"];
        [mailVC setMessageBody:@"内容" isHTML:NO];
        [mailVC setToRecipients:@[@"429267703@qq.com"]];
        [mailVC setSubject:@"主题"];
        //抄送人
        [mailVC setCcRecipients:@[]];
        //密送人
        [mailVC setBccRecipients:@[]];
        
        [self presentViewController:mailVC animated:YES completion:^{
            
        }];
    }
}


#pragma mark MFMailComposeViewControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"邮件发送取消");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"邮件发送失败");
            break;
        case MFMailComposeResultSent:
            NSLog(@"邮件发送成功");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"邮件已保存");
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - 浏览器

-(IBAction)openBrowser:(id)sender{
    NSString* url = @"https://www.baidu.com";
    [self openURL:url];
}

#pragma mark - 通讯录

//info.plist增加权限NSContactsUsageDescription
//通过AddressBook.framework开发者可以从底层去操作AddressBook.framework的所有信息，但是需要注意的是这个框架是基于C语言编写的，无法使用ARC来管理内存，开发者需要自己管理内存。
//AddressBookUI.framework。例如前面查看、新增、修改人员的界面这个框架就提供了现成的控制器视图供开发者使用。

//通讯录的访问步骤一般如下：
//调用ABAddressBookCreateWithOptions()方法创建通讯录对象ABAddressBookRef。
//调用ABAddressBookRequestAccessWithCompletion()方法获得用户授权访问通讯录。
//调用ABAddressBookCopyArrayOfAllPeople()、ABAddressBookCopyPeopleWithName()方法查询联系人信息。
//读取联系人后如果要显示联系人信息则可以调用ABRecord相关方法读取相应的数据；如果要进行修改联系人信息，则可以使用对应的方法修改ABRecord信息，然后调用ABAddressBookSave()方法提交修改；如果要删除联系人，则可以调用ABAddressBookRemoveRecord()方法删除，然后调用ABAddressBookSave()提交修改操作。
//也就是说如果要修改或者删除都需要首先查询对应的联系人，然后修改或删除后提交更改。如果用户要增加一个联系人则不用进行查询，直接调用ABPersonCreate()方法创建一个ABRecord然后设置具体的属性，调用ABAddressBookAddRecord方法添加即可。

-(IBAction)getContactsOld:(id)sender{
    self.addressBook = ABAddressBookCreate(); //需要CFRelease
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
        if (!granted) {
            NSLog(@"未获取通讯录权限");
        }else{
            self.allPerson = [NSMutableArray new];
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(self.addressBook);
            self.allPerson = (__bridge NSMutableArray*)allPeople;
            CFRelease(allPeople);
            
            for (id obj in self.allPerson) {
                ABRecordRef recordRef = (__bridge ABRecordRef)obj;
                //取得记录中得信息
                NSString *firstName=(__bridge NSString *) ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);//注意这里进行了强转，不用自己释放资源
                NSString *lastName=(__bridge NSString *)ABRecordCopyValue(recordRef, kABPersonLastNameProperty);
                if(ABPersonHasImageData(recordRef)){//如果有照片数据
                    NSData *imageData= (__bridge NSData *)(ABPersonCopyImageData(recordRef));
                }
                ABMultiValueRef phoneNumbersRef= ABRecordCopyValue(recordRef, kABPersonPhoneProperty);//获取手机号，注意手机号是ABMultiValueRef类，有可能有多条
                long count= ABMultiValueGetCount(phoneNumbersRef);
                if(count > 0){
                    NSString* phoneNumber = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumbersRef, 0));
                    NSLog(@"firstName %@ lastName %@ phoneNumber %@",firstName,lastName,phoneNumber);
                }
            }
        }
    });
}

//Contacts.framework ios9之后
//info.plist文件中加入如下描述：Privacy - Contacts Usage Description
-(IBAction)getContactsNew:(id)sender{
    CNContactStore* store = [[CNContactStore alloc] init];
    
    switch ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts])
    {
            //存在权限
        case CNAuthorizationStatusAuthorized:{
            //获取通讯录
            CNContactFetchRequest* request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactGivenNameKey]];
            [store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                for (CNLabeledValue<CNPhoneNumber*> * phoneValue in contact.phoneNumbers){
                    
                    NSLog(@"contact name:%@ phoneNumber:%@",contact.givenName,phoneValue.value);
                }
            }];
            
        }
            break;
            
            //权限未知
        case CNAuthorizationStatusNotDetermined:
            //请求权限
            [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                
            }];
            break;
            
            //如果没有权限
        case CNAuthorizationStatusRestricted:
        case CNAuthorizationStatusDenied://需要提示
            break;
    }
}

#pragma mark - 日历

//info.plist增加权限NSCalendarsUsageDescription
//IOS利用EventKit.framework可以实现添加提醒和添加事件（日历）的功能
//Calendar负责记录确定时间要做的事情，以便于到期提醒，或是事后记录某个时间的具体事宜，便于日后备查。其关注的某一时间的行为，重点是时间。提醒事项负责记录要完成的事项列表，通过时间或是地点来提醒，完成的时间可能不确定或是需要跨日期。其关注的重点是待办事宜的完成与否和进度，重点是行为。

-(IBAction)importToCalender:(id)sender{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (error){
            NSLog(@"课程详情.请求日历访问权限失败，error=%@",error);
        } else if (!granted){
            NSLog(@"课程详情.用户拒绝日历访问");
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSDate* startDate = [NSDate date];
                NSDate* endDate = [NSDate date];
                NSString* locationStr = @"轻轻家教";
                
                // 用事件库的实例方法创建谓词 (Create the predicate from the event store's instance method)
                NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate
                                                                             endDate:endDate
                                                                           calendars:[eventStore calendarsForEntityType:EKEntityTypeEvent]];
                
                // 获取所有匹配该谓词的事件(Fetch all events that match the predicate)
                NSArray *events = [eventStore eventsMatchingPredicate:predicate];
                
                BOOL hasImportedToCalender = NO;
                for(EKEvent* event in events){
                    if ([event.startDate isEqualToDate:startDate] && [event.endDate isEqualToDate:endDate] && [event.location isEqualToString:locationStr]) {
                        hasImportedToCalender = YES;
                        break;
                    }
                }
                
                if (!hasImportedToCalender) {
                    //创建事件
                    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                    event.title     = @"标题";
                    event.location = locationStr;
                    
                    event.startDate = startDate;
                    event.endDate   = endDate;
                    //event.allDay = YES;
                    
                    //添加提醒(提前一天)
                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -60.0f * 24]];
                    //关联日历
                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                    //存储事件
                    NSError *err;
                    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                    
                    if (!err) {
                        //[Utils showToastWithText:@"导入日历成功"];
                    }else{
                        //[Utils showToastWithText:@"导入日历失败"];
                    }
                }else{
                    //[Utils showToastWithText:@"已经导入过了"];
                }
            });
        }
    }];
}

#pragma mark - 蓝牙

//info.plist增加权限Privacy - Bluetooth Peripheral Usage Description
//在iOS中进行蓝牙传输应用开发常用的框架有如下几种：
//GameKit.framework：iOS7之前的蓝牙通讯框架，从iOS7开始过期，但是目前多数应用还是基于此框架。
//MultipeerConnectivity.framework：iOS7开始引入的新的蓝牙通讯开发框架，用于取代GameKit。
//CoreBluetooth.framework：功能强大的蓝牙开发框架，要求设备必须支持蓝牙4.0。

-(IBAction)startAdvertiser:(id)sender{
    MCPeerID* peerId = [[MCPeerID alloc] initWithDisplayName:@"广播者"];
    self.advertiserSession = [[MCSession alloc] initWithPeer:peerId];
    self.advertiserSession.delegate = self;
    self.advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:@"cmj-stream" discoveryInfo:nil session:self.advertiserSession];
    [self.advertiserAssistant start];
}

-(IBAction)startBrowser:(id)sender{
    MCPeerID* peerId = [[MCPeerID alloc] initWithDisplayName:@"发现者"];
    self.browserSession = [[MCSession alloc] initWithPeer:peerId];
    self.browserSession.delegate = self;
    self.browerVC = [[MCBrowserViewController alloc] initWithServiceType:@"cmj-stream" session:self.browserSession];
    self.browerVC.delegate = self;
    [self presentViewController:self.browerVC animated:YES completion:^{
        
    }];
}

#pragma mark MCSessionDelegate

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    switch (state) {
        case MCSessionStateConnected:{
            NSLog(@"蓝牙连接成功");
            if (session == self.browserSession) {
                [session sendData:UIImagePNGRepresentation([UIImage imageNamed:@"Demo"]) toPeers:[session connectedPeers] withMode:MCSessionSendDataReliable error:nil];
            }
        }
            break;
        case MCSessionStateNotConnected:{
            NSLog(@"蓝牙连接失败");
        }
            break;
        case MCSessionStateConnecting:{
            NSLog(@"蓝牙连接中。。。");
        }
            break;
        default:
            break;
    }
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSLog(@"%s",__FUNCTION__);
    if (session == self.advertiserSession) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage* image = [UIImage imageWithData:data];
            self.receiveImageView.image = image;
        });
    }
}

#pragma mark MCBrowserViewControllerDelegate

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 社交

//苹果官方默认支持的分享并不太多，特别是对于国内的应用只支持新浪微博和腾讯微博（事实上从iOS7苹果才考虑支持腾讯微博）。目前最好的选择就是使用第三方框架，因为如果要自己实现各个应用的接口还是比较复杂的。当前使用较多的就是友盟社会化组件、ShareSDK，而且现在百度也出了社会化分享组件。

-(IBAction)shareToSina:(id)sender{
    //检查新浪微博服务是否可用
    if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]){
        NSLog(@"新浪微博服务不可用.");
        return;
    }
    //初始化内容编写控制器，注意这里指定分享类型为新浪微博
    SLComposeViewController *composeController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
    //设置默认信息
    [composeController setInitialText:@"Kenshin Cui's Blog..."];
    //添加图片
    [composeController addImage:[UIImage imageNamed:@"stevenChow"]];
    //添加连接
    [composeController addURL:[NSURL URLWithString:@"http://www.cnblogs.com/kenshincui"]];
    //设置发送完成后的回调事件
    __block SLComposeViewController *composeControllerForBlock=composeController;
    composeController.completionHandler=^(SLComposeViewControllerResult result){
        if (result==SLComposeViewControllerResultDone) {
            NSLog(@"开始发送...");
        }
        [composeControllerForBlock dismissViewControllerAnimated:YES completion:nil];
    };
    //显示编辑视图
    [self presentViewController:composeController animated:YES completion:nil];
}


#pragma mark - GameCenter

//Game Center是由苹果发布的在线多人游戏社交网络，通过它游戏玩家可以邀请好友进行多人游戏，它也会记录玩家的成绩并在排行榜中展示，同时玩家每经过一定的阶段会获得不同的成就。这里就简单介绍一下如何在自己的应用中集成Game Center服务来让用户获得积分、成就以及查看游戏排行和已获得成就。

#pragma mark - 应用内购买

//大家都知道做iOS开发本身的收入有三种来源：出售应用、内购和广告。内购营销模式，通常软件本身是不收费的，但是要获得某些特权就必须购买一些道具，而内购的过程是由苹果官方统一来管理的

#pragma mark - 广告
//在iOS上有很多广告服务可以集成，使用比较多的就是苹果的iAd、谷歌的Admob，下面简单演示一下如何使用iAd来集成广告。使用iAd集成广告的过程比较简单，首先引入iAd.framework框架，然后创建ADBannerView来展示广告，通常会设置ADBannerView的代理方法来监听广告点击并在广告加载失败时隐藏广告展示控件。
//首先你已经参加了那个99刀的开发者计划。之后需要在iTunes Connect的账户中申请加入iAd Network。

#pragma mark ADBannerViewDelegate

-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
    NSLog(@"%s",__FUNCTION__);
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    NSLog(@"%s",__FUNCTION__);
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"%s",__FUNCTION__);
    //广告不是你想有，想有就能有的
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
//这个方法在用户点击Banner的时候调用。用户点击Banner之后，会出现一个modal view现实全屏广告。当这个全屏广告出现的时候任何用户相关的活动都需要暂停。这里返回的是YES，如果返回的是NO的话，用户点击了Banner之后不会出现全屏的广告。
    return YES;
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner{
    //这个方法在全屏的广告退出的时候调用。在这里，全屏广告出现时暂停的全部动作又可以开始运行。
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - iCloud

//iCloud是苹果提供的云端服务，用户可以将通讯录、备忘录、邮件、照片、音乐、视频等备份到云服务器并在各个苹果设备间直接进行共享而无需关心数据同步问题，甚至即使你的设备丢失后在一台新的设备上也可以通过Apple ID登录同步。当然这些内容都是iOS内置的功能，那么对于开放者如何利用iCloud呢？苹果已经将云端存储功能开放给开发者，利用iCloud开发者可以存储两类数据：用户文档和应用数据、应用配置项。前者主要用于一些用户文档、文件的存储，后者更类似于日常开放中的偏好设置，只是这些配置信息会同步到云端。

#pragma mark - Passbook

//Passbook是苹果推出的一个管理登机牌、会员卡、电影票、优惠券等信息的工具。Passbook就像一个卡包，用于存放你的购物卡、积分卡、电影票、礼品卡等，而这些票据就是一个“Pass”。和物理票据不同的是你可以动态更新Pass的信息，提醒用户优惠券即将过期；甚至如果你的Pass中包含地理位置信息的话当你到达某个商店还可以动态提示用户最近商店有何种优惠活动；当用户将一张团购券添加到Passbook之后，用户到了商店之后Passbook可以自动弹出团购券，店员扫描之后进行消费、积分等等都是Passbook的应用场景。Passbook可以管理多类票据，苹果将其划分为五类：
//登机牌（Boarding pass）
//优惠券（Coupon）
//活动票据、入场券（Event ticket）
//购物卡、积分卡（Store Cards）
//普通票据(自定义票据)（Generic pass）

#pragma mark - 其他跳转（系统设置）

-(IBAction)jumpToNotificationSetting:(id)sender{
    //判断是否开启通知权限
    BOOL isOpenPushNotification = NO;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        isOpenPushNotification = ([[UIApplication sharedApplication] currentUserNotificationSettings].types  != UIRemoteNotificationTypeNone);
    }else{
        isOpenPushNotification = ([[UIApplication sharedApplication] enabledRemoteNotificationTypes]  != UIRemoteNotificationTypeNone);
    }

    //调整通知权限设置页
    NSURL * url = nil;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    }else{
        url= [NSURL URLWithString:@"prefs:root=NOTIFICATIONS_ID"];
    }
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            }];
        }else{
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}


@end

#pragma mark - 支持跳转到当前APP

//需在plist文件中添加URL types节点并配置URL Schemas作为具体协议，配置URL identifier作为这个URL的唯一标识
//然后在AppDelegate中实现跳转处理
@interface AppDelegate (Extension) <UIApplicationDelegate>

@end

@implementation AppDelegate (Extension)

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

