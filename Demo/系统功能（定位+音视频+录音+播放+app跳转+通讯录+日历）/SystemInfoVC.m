//
//  SystemInfoVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/4/19.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "SystemInfoVC.h"
#import <AdSupport/AdSupport.h>

#import <sys/types.h>
#import <sys/sysctl.h>
#import <mach/host_info.h>
#import <mach/mach_host.h>
#import <mach/task_info.h>
#import <mach/task.h>

@interface SystemInfoVC ()

@end

@implementation SystemInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[self class] idfa];
    [[self class] systemName];
    [[self class] systemVersion];
    [[self class] appName];
    [[self class] appVersion];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SystemInfo

+(NSString*)systemName{
    NSString* systemName = [UIDevice currentDevice].systemName;
    NSLog(@"systemName:%@",systemName);
    return systemName;
}

+(NSString*)systemVersion{
    NSString* systemVersion = [UIDevice currentDevice].systemVersion;
    NSLog(@"systemVersion:%@",systemVersion);
    return systemVersion;
}

#pragma mark - AppInfo

+ (NSString*)appName{
    NSString* appName = [[NSBundle mainBundle] bundleIdentifier];
//    appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
//    appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSLog(@"appName:%@",appName);
    return appName;
}

+ (NSString*)appVersion{
    NSString* appShortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString* appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    NSLog(@"appShortVersion:%@ appVersion:%@",appShortVersion,appVersion);
    return appVersion;
}

+ (NSString *)appSchema:(NSString *)name {
    NSArray * array = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"];
    for ( NSDictionary * dict in array ) {
        if ( name ) {
            NSString * URLName = [dict objectForKey:@"CFBundleURLName"];
            if ( nil == URLName ) {
                continue;
            }
            
            if ( NO == [URLName isEqualToString:name] ) {
                continue;
            }
        }
        
        NSArray * URLSchemes = [dict objectForKey:@"CFBundleURLSchemes"];
        if ( nil == URLSchemes || 0 == URLSchemes.count ) {
            continue;
        }
        
        NSString * schema = [URLSchemes objectAtIndex:0];
        if ( schema && schema.length )
        {
            return schema;
        }
    }
    
    return nil;
}

#pragma mark - 设备信息：电池，屏幕，CPU,内存，磁盘，进程，网络状态。。

//IDFA 是苹果 iOS 6 开始新增的广告标识符，英文全称是 Identifier for Advertising ，用于给开发者跟踪广告效果用的，可以简单理解为 iPhone 的设备临时身份证，说是临时身份证是因为它允许用户更换，IDFA 存储在用户 iOS 系统上，同一设备上的应用获取到的 IDFA 是相同的。iOS 用户可以通过（设置程序 -> 通用 -> 还原 -> 还原位置与隐私）更换 IDFA，iOS 10 系统开始提供禁止广告跟踪功能，用户勾选这个功能后，应用程序将无法读取到设备的 IDFA。
//IDFA 是目前苹果生态广告交易的主要标识，一般跟广告商交易一个用户后广告商需要给你提供用户的 IDFA 作为凭证，主流的广告平台腾讯广点通、新浪粉丝通对账是基于 IDFA 的。

//IOS7之后，苹果的UUID，MAC等信息都不可获取，IDFA一统天下。

+(NSString*)idfa{
    //可能拿到全是0，也可能会变化
    NSString* idfa = [ASIdentifierManager sharedManager].advertisingIdentifier.UUIDString;
    NSLog(@"idfa:%@",idfa);
    return idfa;
}

-(void)batteryInfo{
    NSLog(@"betteryStatus %ld betteryLevel %f",[UIDevice currentDevice].batteryState,[UIDevice currentDevice].batteryLevel);
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    //处理监听通知：UIDeviceBatteryStateDidChangeNotification，UIDeviceBatteryLevelDidChangeNotification
}

// 打印设备内存信息
+ (void) logMemoryInfo {
    int mib[6];
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    
    int pagesize;
    size_t length;
    length = sizeof (pagesize);
    if (sysctl (mib, 2, &pagesize, &length, NULL, 0) < 0)
    {
        fprintf (stderr, "getting page size");
    }
    
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    
    vm_statistics_data_t vmstat;
    if (host_statistics (mach_host_self (), HOST_VM_INFO, (host_info_t) &vmstat, &count) != KERN_SUCCESS)
    {
        fprintf (stderr, "Failed to get VM statistics.");
    }
    task_basic_info_64_data_t info;
    unsigned size = sizeof (info);
    task_info (mach_task_self (), TASK_BASIC_INFO_64, (task_info_t) &info, &size);
    
    double unit = 1024 * 1024;
    double total = (vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count) * pagesize / unit;
    double wired = vmstat.wire_count * pagesize / unit;
    double active = vmstat.active_count * pagesize / unit;
    double inactive = vmstat.inactive_count * pagesize / unit;
    double free = vmstat.free_count * pagesize / unit;
    double resident = info.resident_size / unit;
    NSLog(@"===================================================");
    NSLog(@"Total:%.2lfMb", total);
    NSLog(@"Wired:%.2lfMb", wired);
    NSLog(@"Active:%.2lfMb", active);
    NSLog(@"Inactive:%.2lfMb", inactive);
    NSLog(@"Free:%.2lfMb", free);
    NSLog(@"Resident:%.2lfMb", resident);
}

// 获取当前设备可用内存(单位：MB)
+ (double)availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    return ((vm_page_size *vmStats.free_count)/1024.0)/1024.0;
}

// 获取当前任务所占用的内存（单位：MB）
+ (double)usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),TASK_BASIC_INFO,(task_info_t)&taskInfo, &infoCount);
    if(kernReturn!=KERN_SUCCESS) {
        return NSNotFound;
    }
    return taskInfo.resident_size / 1024.0 / 1024.0;
}


#pragma mark 自动转屏

//Phone的加速计是整个IOS屏幕旋转的基础，依赖加速计，设备才可以判断出当前的设备方向, 当手机检测到设备方向发生变化的时候会进行如下的操作.
//设备旋转的时候，UIKit接收到旋转事件
//UIKit通过AppDelegate通知当前程序的window
//Window会知会它的rootViewController，判断该view controller所支持的旋转方向，完成旋转
//如果存在弹出的view controller的话，系统则会根据弹出的view controller，来判断是否要进行旋转
//如果view controller支持旋转,他的view的bounds就会发生变化, 将会调用viewWillLayoutSubviews()等方法重新布局

//支持自动转屏流程：
//首先，对于任意一个viewController，iOS会以info.plist中的设置和当前viewController的preferredInterfaceOrientationForPresentation和supportedInterfaceOrientations三者支持的方法做一个交运算，若交集不为空，则以preferredInterfaceOrientationForPresentation为初始方向，交集中的所有方向均支持，但仅在shouldAutorotate返回YES时，允许从初始方向旋转至其他方向。若交集为空，进入viewController时即crash，错误信息中会提示交集为空。
//其次，UINavigationController稍有些特别，难以用常规API做到同一个naviVC中的ViewController在不同方向间自如地切换。(如果去SO之类的地方搜索，会找到一个present empty viewController and then dismiss it之类的hacky trick，不太建议使用)，如果要在横竖屏间切换，建议使用presentXXX方法。
//再次，AppDelegate中有一个委托方法可以动态的设置应用支持的旋转方向，且此委托的返回值会覆盖info.plist中的固定设置。使用该方法的便利之处不言自明，但缺点是搞明白当前哪个ViewController即将要被显示，很可能会导致耦合增加；
//最后，以上均为个人在iOS8 SDK下得到的实践结果，请题主结合工程实际参考使用。

- (BOOL)shouldAutorotate{
    //是否允许转屏(手动旋转时要为YES)
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    //viewController所支持的全部旋转方向
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    //viewController初始显示的方向
    return UIInterfaceOrientationPortrait;
}

#pragma mark  手动转屏

- (IBAction)rotateScreen:(id)sender{
    NSNumber* value = [NSNumber numberWithInt:UIDeviceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

@end

#pragma mark - 自动转屏扩展

@interface UINavigationController (Autorotate)

@end

@implementation UINavigationController (Autorotate)

- (BOOL)shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

@end


@interface UITabBarController (Autorotate)

@end

@implementation UITabBarController (Autorotate)

- (BOOL)shouldAutorotate
{
    return [self.selectedViewController shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.selectedViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.selectedViewController preferredInterfaceOrientationForPresentation];
}

@end
