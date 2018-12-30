//
//  3DTouchVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/11/26.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "3DTouchVC.h"
#import "AppDelegate.h"

//开发环境及调试设备：Xcode7或以上，iOS9或以上，iPhone6s或以上
//3DTouch功能主要分为两大块：主屏幕Icon上的快捷标签（Home Screen Quick Actions）； Peek（预览）和Pop（跳至预览的详细界面）
//主屏幕icon上的快捷标签的实现方式有两种，一种是在工程文件info.plist里静态设置，另一种是代码的动态实现。

//http://www.jianshu.com/p/95c20308cb5f

@interface AppDelegate (_DTouch)

@end

@implementation AppDelegate (_DTouch)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    if(@available(iOS 9.0,*)) {
        UIApplicationShortcutItem* shortcutItem = launchOptions[UIApplicationLaunchOptionsShortcutItemKey];
        if ([shortcutItem.type isEqualToString:@"com.qq.gavin"]) {
            NSLog(@"启动点击了3DTouch中的gavin");
        }
    }
    
    return YES;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{
    
    if ([shortcutItem.type isEqualToString:@"com.qq.gavin"]) {
        NSLog(@"后台点击了3DTouch中的gavin");
    }
}

@end

@interface _DTouchVC () <UIViewControllerPreviewingDelegate>

@end

@implementation _DTouchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView* touchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    touchView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:touchView];
    
    //注册3DTouch
    [self registerForPreviewingWithDelegate:self sourceView:touchView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Home Screen Quick Actions

- (void)createIconItems{
    
    UIApplicationShortcutIcon* icon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeHome];
    UIApplicationShortcutItem* item = [[UIApplicationShortcutItem alloc] initWithType:@"com.qq.gavin" localizedTitle:@"gavin" localizedSubtitle:nil icon:icon userInfo:nil];
    [UIApplication sharedApplication].shortcutItems = @[item];
}

#pragma mark - UIViewControllerPreviewingDelegate Peek预览&Pop进入

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location NS_AVAILABLE_IOS(9_0){
    
    //获取按压的cell所在行，[previewingContext sourceView]就是按压的那个视图
    //    NSIndexPath *indexPath = [_myTableView indexPathForCell:(UITableViewCell* )[previewingContext sourceView]];
    
    //设定预览的界面
    UIViewController *childVC = [[UIViewController alloc] init];
    childVC.view.backgroundColor = [UIColor yellowColor];
    childVC.preferredContentSize = CGSizeMake(0.0f,500.0f);
    
    //调整不被虚化的范围，按压的那个cell不被虚化（轻轻按压时周边会被虚化，再少用力展示预览，再加力跳页至设定界面）
    CGRect rect = CGRectMake(0, 0, previewingContext.sourceView.frame.size.width*2,previewingContext.sourceView.frame.size.height*2);
    previewingContext.sourceRect = rect;
    //返回预览界面
    return childVC;
}

//pop（按用点力进入）
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit NS_AVAILABLE_IOS(9_0){
    
    UIViewController *childVC = [[UIViewController alloc] init];
    childVC.view.backgroundColor = [UIColor redColor];
    
    [self.navigationController pushViewController:childVC animated:YES];
    
    //    不需要3DTouch时反注册
    //    [self unregisterForPreviewingWithContext:previewingContext];
}

#pragma mark - 当弹出预览时，上滑预览视图，出现预览视图中快捷选项

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    // setup a list of preview actions
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"删除" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"点击了预览选项");
    }];
    return @[action1];
}

@end
