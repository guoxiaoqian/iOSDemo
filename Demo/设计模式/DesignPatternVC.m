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

#import "CommandPattern_Light.h"
#import "LightCommand_On.h"
#import "LightCommand_Off.h"

#import "CompositePattern_CompositeLight.h"
#import "CompositePattern_Light.h"

#import "BridgePattern_BigLight.h"
#import "BridgePattern_BlueColor.h"

#import "DecoratorPattern_Light.h"
#import "DecoratorPattern_HotDecorator.h"
#import "DecoratorPattern_ColorDecorator.h"

@interface DesignPatternVC ()

@end

@implementation DesignPatternVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self statePattern];
    [self commandPattern];
    [self compositePattern];
    [self bridgePattern];
    [self decoratorPattern];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)statePattern{
    StatePattern_Light* light = [[StatePattern_Light alloc] initWithState:[LightState_Off new]];
    [light pressSwitch];
    [light pressSwitch];
}

-(void)commandPattern{
    CommandPattern_Light* light = [[CommandPattern_Light alloc] init];
    LightCommand* command_on = [[LightCommand_On alloc] initWithLight:light];
    LightCommand* command_off = [[LightCommand_Off alloc] initWithLight:light];
    [command_on execute];
    [command_off execute];
}

-(void)compositePattern{
    CompositePattern_AbstractLight* light = [CompositePattern_Light new];
    CompositePattern_AbstractLight* light2 = [CompositePattern_Light new];
    CompositePattern_AbstractLight* lights = [[CompositePattern_CompositeLight alloc] initWithLights:@[light,light2]];
    [lights lightOn];
}

-(void)bridgePattern{
    BridgePattern_AbstractLight* light = [BridgePattern_BigLight new];
    BridgePattern_AbstractColor* color = [BridgePattern_BlueColor new];
    [light showColor:color];
}

-(void)decoratorPattern{
    DecoratorPattern_AbstractLight* light = [DecoratorPattern_Light new];
    light = [[DecoratorPattern_ColorDecorator alloc] initWithLight:light];
    light = [[DecoratorPattern_HotDecorator alloc] initWithLight:light];
    [light lightOn];
}


@end
