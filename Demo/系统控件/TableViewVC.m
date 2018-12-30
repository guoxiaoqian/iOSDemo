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
        self.height = 200;
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
    
    CGFloat navBarHeight = 44 + [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat viewOriginY = navBarHeight;
    CGFloat viewHeight = self.view.bounds.size.height - navBarHeight;
    
    UIButton* btn_reload = [[UIButton alloc] initWithFrame:CGRectMake(0, viewOriginY, 80, 50)];
    [btn_reload setTitle:@"reload" forState:UIControlStateNormal];
    [btn_reload addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_reload];
    
    UIButton* btn_reloadFirst = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btn_reload.frame) + 10, viewOriginY, 80, 50)];
    [btn_reloadFirst setTitle:@"reloadFirst" forState:UIControlStateNormal];
    [btn_reloadFirst addTarget:self action:@selector(reloadFirstItem) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_reloadFirst];
    
    UIButton* btn_reloadLast = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btn_reloadFirst.frame) + 10, viewOriginY, 80, 50)];
    [btn_reloadLast setTitle:@"reloadLast" forState:UIControlStateNormal];
    [btn_reloadLast addTarget:self action:@selector(reloadLastItem) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_reloadLast];

    UIButton* btn_reloadFirstOnly = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btn_reloadLast.frame) + 10, viewOriginY, 80, 50)];
    [btn_reloadFirstOnly setTitle:@"reloadFirstOnly" forState:UIControlStateNormal];
    [btn_reloadFirstOnly addTarget:self action:@selector(reloadFirstItemOnly) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_reloadFirstOnly];
    
    self.modelArray = [NSMutableArray new];
    for (int i = 0; i < 2; ++i) {
        NSMutableArray* section = [NSMutableArray new];
        for (int j = 0; j < 4; ++j) {
            [section addObject:[TableViewCellModel new]];
        }
        [self.modelArray addObject:section];
    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btn_reload.frame), self.view.bounds.size.width, viewHeight - CGRectGetHeight(btn_reload.frame)) style:UITableViewStylePlain];
    self.tableView.contentInset = UIEdgeInsetsZero;
    [self addObserver:self forKeyPath:@"tableView.contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:@"tableView.contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"tableView.contentSize"]) {
        NSLog(@"contentSize %@",change[NSKeyValueChangeNewKey]);
    } else if ([keyPath isEqualToString:@"tableView.contentOffset"]) {
        NSLog(@"contentOffset %@",change[NSKeyValueChangeNewKey]);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removeObserver:self forKeyPath:@"tableView.contentSize"];
    [self removeObserver:self forKeyPath:@"tableView.contentOffset"];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"%s",__FUNCTION__);
    
    return  self.modelArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%s section %zd",__FUNCTION__,section);
    
    NSArray* sectionModels = self.modelArray[section];
    return sectionModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s section %zd row %zd",__FUNCTION__,indexPath.section,indexPath.row);
    
    TableViewCellModel* model = self.modelArray[indexPath.section][indexPath.row];
    UITableViewCell* cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [NSString stringWithFormat:@"%d",model.height];
    
    return cell;
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
    NSLog(@"%s section %zd row %zd",__FUNCTION__,indexPath.section,indexPath.row);
}
//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section  {
//    NSLog(@"%s",__FUNCTION__);
//}
//- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section  {
//    NSLog(@"%s",__FUNCTION__);
//}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    NSLog(@"%s section %zd row %zd",__FUNCTION__,indexPath.section,indexPath.row);
}
//- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section  {
//    NSLog(@"%s",__FUNCTION__);
//}
//- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section  {
//    NSLog(@"%s",__FUNCTION__);
//}

// Variable height support

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s section %zd row %zd",__FUNCTION__,indexPath.section,indexPath.row);

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

- (void)reloadData {
    [self.tableView reloadData];
}

- (void)reloadFirstItem {
    TableViewCellModel* firstModel = self.modelArray[0][0];
    firstModel.height = 300;
    [self.tableView reloadData];
}

- (void)reloadLastItem {
    TableViewCellModel* lastModel = [self.modelArray.lastObject lastObject];
    lastModel.height = 300;
    [self.tableView reloadData];
}

- (void)reloadFirstItemOnly {
    TableViewCellModel* firstModel = self.modelArray[0][0];
    firstModel.height = 300;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

@end
