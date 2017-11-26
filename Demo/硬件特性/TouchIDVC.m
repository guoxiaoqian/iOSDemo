//
//  TouchIDVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/11/26.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "TouchIDVC.h"
#import <LocalAuthentication/LocalAuthentication.h>

//设备要求：iphone5s以上 + iOS8以上
//需要引入框架 LocalAuthentication.framework
//链接：http://www.jianshu.com/p/9b0aa6b9c689

@interface TouchIDVC ()

@end

@implementation TouchIDVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)authByTouchId{
    
    LAContext *laContext = [[LAContext alloc] init];
    NSError *error;
    
    if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        
        [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:@"Touch Id Test"
                            reply:^(BOOL success, NSError *error) {
                                if (success) {
                                    NSLog(@"success to evaluate");
                                }
                                if (error) {
                                    NSLog(@"---failed to evaluate---error: %@---", error.description);
                                    //判断具体errorCode,在LAError中都定义了
                                }
                            }];
    }
    else {
        NSLog(@"==========Not support :%@", error.description);
    }
    
}

@end
