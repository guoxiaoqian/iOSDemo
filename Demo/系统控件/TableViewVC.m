//
//  TableViewTestVC.m
//  Demo
//
//  Created by 郭晓倩 on 2018/12/27.
//  Copyright © 2018年 郭晓倩. All rights reserved.
//

#import "TableViewVC.h"

@interface TableViewCellModel : NSObject

@property (assign,nonatomic) int delay;
@property (assign,nonatomic) int height;

@end

@implementation TableViewCellModel

- (instancetype)init {
    if (self = [super init]) {
        self.delay = arc4random_uniform(10) + 2;
        self.height = arc4random_uniform(60) + 20;
    }
    return self;
}

@end

@interface TableViewVC () <UITableViewDataSource,UITableViewDelegate>

@property (strong,nonatomic) UITableView* tableView;
@property (strong,nonatomic) NSMutableArray* modelArray;

@end

@implementation TableViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.modelArray = [NSMutableArray new];
    for (int i = 0; i < 3; ++i) {
        NSMutableArray* section = [NSMutableArray new];
        for (int j = 0; j < 3; ++j) {
            [section addObject:[TableViewCellModel new]];
        }
        [self.modelArray addObject:section];
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Sequence %s",__FUNCTION__);
    NSArray* sectionModels = self.modelArray[section];
    return sectionModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Sequence %s",__FUNCTION__);
    TableViewCellModel* model = self.modelArray[indexPath.section][indexPath.row];

    UITableViewCell* cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [NSString stringWithFormat:@"%d",model.delay];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"Sequence %s",__FUNCTION__);

    return  self.modelArray.count;
}

//- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//
//}
//- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
//
//}

#pragma mark - UITableViewDelegate

// Display customization

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Sequence %s",__FUNCTION__);
}
//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section  {
//    NSLog(@"Sequence %s",__FUNCTION__);
//}
//- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section  {
//    NSLog(@"Sequence %s",__FUNCTION__);
//}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    NSLog(@"Sequence %s",__FUNCTION__);
}
//- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section  {
//    NSLog(@"Sequence %s",__FUNCTION__);
//}
//- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section  {
//    NSLog(@"Sequence %s",__FUNCTION__);
//}

// Variable height support

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Sequence %s",__FUNCTION__);

    TableViewCellModel* model = self.modelArray[indexPath.section][indexPath.row];

    return model.height;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//
//}

// Section header & footer information. Views are preferred over title should you decide to provide both

//- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//
//}
//- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//
//}

@end
