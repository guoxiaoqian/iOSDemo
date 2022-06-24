//
//  ViewController.m
//  Demo
//
//  Created by 郭晓倩 on 17/2/14.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "ViewController.h"
#import "CoreDataVC.h"
#import "FMDBVC.h"
#import "FileManagerVC.h"
#import "NetworkVC.h"
#import "CoreLocationVC.h"
#import "QuartzDemoVC.h"
#import "TestGeneralAnimationVC.h"
#import "CoreGraphicVC.h"
#import "CoreAnimationVC.h"
#import "CubeVC.h"
#import "SpecialLayerVC.h"
#import "EventVC.h"
#import "RemoteEnvetVC.h"
#import "MediaVC.h"
#import "ConcurrencyVC.h"
#import "RuntimeVC.h"
#import "SystemAppVC.h"
#import "SystemInfoVC.h"
#import "NotificationVC.h"
#import "H5VC.h"
#import "AutoLayoutVC.h"
#import "FunctionVC.h"
#import "RunloopVC.h"
#import "AlgorithmVC.h"
#import "DataStructureVC.h"
#import "DesignPatternVC.h"
#import "3DTouchVC.h"
#import "TouchIDVC.h"
#import "QRCodeVC.h"
#import "ReactiveVC.h"
#import "UnixSignalVC.h"
#import "TableViewVC.h"
#import "SerializeVC.h"
#import "MachExceptionVC.h"
#import "BankCompare.h"
#import "CrashVC.h"
#import "MakeFuzzyVC.h"
#import "SelfSizingVC.h"
#import "BlurEffectVC.h"
#import "CppTestVC.h"
#import "PresentVC.h"
#import "FlexMessageVC.h"
#import "FlutterTestVC.h"
#import "MemoryVC.h"
#import "TestLockVC.h"
#import "TimeVC.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [NSMutableArray arrayWithObjects:
                       [EntryModel modelWithName:@"Core Data" class:[CoreDataVC class]],
                       [EntryModel modelWithName:@"FMDB" class:[FMDBVC class]],
                       [EntryModel modelWithName:@"File Manager" class:[FileManagerVC class]],
                       [EntryModel modelWithName:@"Network" class:[NetworkVC class]],
                       [EntryModel modelWithName:@"CoreLocation" class:[CoreLocationVC class]],
                       [EntryModel modelWithName:@"AutoLayoutVC" class:[AutoLayoutVC class]],
                       [EntryModel modelWithName:@"Quartz2DDemo" class:[QuartzDemoVC class]],
                       [EntryModel modelWithName:@"CoreGraphic" class:[CoreGraphicVC class]],
                       [EntryModel modelWithName:@"CoreAnimationDemo" class:[TestGeneralAnimationVC class]],
                       [EntryModel modelWithName:@"CoreAnimation" class:[CoreAnimationVC class]],
                       [EntryModel modelWithName:@"CubeVC" class:[CubeVC class]],
                       [EntryModel modelWithName:@"SpecialLayerVC" class:[SpecialLayerVC class]],
                       [EntryModel modelWithName:@"EventVC" class:[EventVC class]],
                       [EntryModel modelWithName:@"RemoteEventVC" class:[RemoteEnvetVC class]],
                       [EntryModel modelWithName:@"MediaVC" class:[MediaVC class]],
                       [EntryModel modelWithName:@"ConcurrencyVC" class:[ConcurrencyVC class]],
                       [EntryModel modelWithName:@"RunloopVC" class:[RunloopVC class]],
                       [EntryModel modelWithName:@"FunctionVC" class:[FunctionVC class]],
                       [EntryModel modelWithName:@"RuntimeVC" class:[RuntimeVC class]],
                       [EntryModel modelWithName:@"SystemAppVC" class:[SystemAppVC class]],
                       [EntryModel modelWithName:@"SystemInfoVC" class:[SystemInfoVC class]],
                       [EntryModel modelWithName:@"NotificationVC" class:[NotificationVC class]],
                       [EntryModel modelWithName:@"H5VC" class:[H5VC class]],
                       [EntryModel modelWithName:@"DesignPatternVC" class:[DesignPatternVC class]],
                       [EntryModel modelWithName:@"DataStructureVC" class:[DataStructureVC class]],
                       [EntryModel modelWithName:@"AlgorithmVC" class:[AlgorithmVC class]],
                       [EntryModel modelWithName:@"3DTouchVC" class:[_DTouchVC class]],
                       [EntryModel modelWithName:@"TouchIDVC" class:[TouchIDVC class]],
                       [EntryModel modelWithName:@"QRCodeVC" class:[QRCodeVC class]],
                       [EntryModel modelWithName:@"ReactiveVC" class:[ReactiveVC class]],
                       [EntryModel modelWithClass:[UnixSignalVC class]],
                       [EntryModel modelWithClass:[TableViewVC class]],
                       [EntryModel modelWithClass:[SerializeVC class]],
                       [EntryModel modelWithClass:[MachExceptionVC class]],
                       [EntryModel modelWithClass:[BankCompare class]],
                       [EntryModel modelWithClass:[CrashVC class]],
                       [EntryModel modelWithClass:[MakeFuzzyVC class]],
                       [EntryModel modelWithClass:[SelfSizingVC class]],
                       [EntryModel modelWithClass:[BlurEffectVC class]],
                       [EntryModel modelWithClass:[CppTestVC class]],
                       [EntryModel modelWithClass:[PresentVC class]],
                       [EntryModel modelWithClass:[FlexMessageVC class]],
                       [EntryModel modelWithClass:[FlutterTestVC class]],
                       [EntryModel modelWithClass:[MemoryVC class]],
                       [EntryModel modelWithClass:[TestLockVC class]],
                       [EntryModel modelWithClass:[TimeVC class]],
                       nil];
}

@end
