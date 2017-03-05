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
                       nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
