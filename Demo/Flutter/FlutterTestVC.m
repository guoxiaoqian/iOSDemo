//
//  FlutterTestVC.m
//  Demo
//
//  Created by gavinxqguo on 2020/11/26.
//  Copyright © 2020 郭晓倩. All rights reserved.
//

@import Flutter;
#import "FlutterTestVC.h"
#import "AppDelegate.h"

@interface FlutterTestVC ()

@end

@implementation FlutterTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self showFlutter];
}

- (void)showFlutter {
    FlutterEngine *flutterEngine =
        ((AppDelegate *)UIApplication.sharedApplication.delegate).flutterEngine;
    
    if (flutterEngine == nil) {
        flutterEngine = [[FlutterEngine alloc] initWithName:@"my flutter engine"];
        [flutterEngine run];
        ((AppDelegate *)UIApplication.sharedApplication.delegate).flutterEngine = flutterEngine;
    }
    
    FlutterViewController *flutterViewController =
        [[FlutterViewController alloc] initWithEngine:flutterEngine nibName:nil bundle:nil];
    [self presentViewController:flutterViewController animated:YES completion:nil];
}
@end
