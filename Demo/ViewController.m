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
#import "CrashSignalVC.h"
#import "TableViewVC.h"
#import "SerializeVC.h"
#import "CrashVC.h"

@interface EntryModel : NSObject

@property (strong,nonatomic) NSString* name;
@property (strong,nonatomic) Class targetVCClass;

@end

@implementation EntryModel

+(EntryModel*)modelWithName:(NSString*)name class:(Class)class{
    EntryModel* model = [EntryModel new];
    model.name = name;
    model.targetVCClass = class;
    return model;
}

+(EntryModel*)modelWithClass:(Class)class{
    return [self modelWithName:NSStringFromClass(class) class:class];
}

@end

@interface ViewController ()

@property (strong,nonatomic) NSMutableArray* dataSource;

@end

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
                       [EntryModel modelWithClass:[CrashSignalVC class]],
                       [EntryModel modelWithClass:[TableViewVC class]],
                       [EntryModel modelWithClass:[SerializeVC class]],
                       [EntryModel modelWithClass:[CrashVC class]],

                       nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    LOG_FUNCTION;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    LOG_FUNCTION;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell =  [UITableViewCell new];
    EntryModel* model = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = model.name;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EntryModel* model = [self.dataSource objectAtIndex:indexPath.row];
    UIViewController* vc = [[model.targetVCClass alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
