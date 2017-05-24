//
//  DesignPatternVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/5/23.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "DesignPatternVC.h"
#import "StatePattern_Light.h"
#import "LightState_Off.h"

@interface DesignPatternVC ()

@end

@implementation DesignPatternVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    StatePattern_Light* light = [[StatePattern_Light alloc] initWithState:[LightState_Off new]];
    [light pressSwitch];
    [light pressSwitch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
