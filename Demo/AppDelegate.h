//
//  AppDelegate.h
//  Demo
//
//  Created by 郭晓倩 on 17/2/14.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import <UIKit/UIKit.h>

#if ENABLE_FLUTTER
@import Flutter;
@interface AppDelegate : FlutterAppDelegate <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) FlutterEngine *flutterEngine;
@end
#else
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end
#endif

