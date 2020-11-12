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
        self.height = 50;
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
    
    UIButton* btn_edit = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btn_reloadFirstOnly.frame) + 10, 80, 50)];
    [btn_edit setTitle:@"edit" forState:UIControlStateNormal];
    [btn_edit addTarget:self action:@selector(editTable) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_edit];
    
    self.modelArray = [NSMutableArray new];
    NSMutableArray* section1 = [NSMutableArray new];
    [section1 addObject:[TableViewCellModel new]];
    [self.modelArray addObject:section1];

    for (int i = 0; i < 2; ++i) {
        NSMutableArray* section = [NSMutableArray new];
        for (int j = 0; j < 4; ++j) {
            [section addObject:[TableViewCellModel new]];
        }
        [self.modelArray addObject:section];
    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btn_edit.frame), self.view.bounds.size.width, viewHeight - CGRectGetHeight(btn_reload.frame)) style:UITableViewStyleGrouped];
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
    
    if (indexPath.section == 0) {
        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCellStyleSubtitle"];
        cell.textLabel.text = @"我是大标题";
        cell.detailTextLabel.text = @"我是小标题";
        cell.accessoryView = [[UISwitch alloc] init];
        return cell;
    } else {
        TableViewCellModel* model = self.modelArray[indexPath.section][indexPath.row];
        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellStyleDefault"];
        cell.imageView.image = [UIImage imageNamed:@"Demo.png"];
        cell.textLabel.text = [NSString stringWithFormat:@"%d",model.height];
        return cell;
    }
}

//- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//
//}
//- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
//
//

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s section %zd row %zd",__FUNCTION__,indexPath.section,indexPath.row);
    if (indexPath.section > 0) {
        return YES;
    } else {
        return NO;
    }
}

// Moving/reordering

// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s section %zd row %zd",__FUNCTION__,indexPath.section,indexPath.row);
    if (indexPath.section == 1) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s section %zd row %zd",__FUNCTION__,indexPath.section,indexPath.row);
}

// Data manipulation - reorder / moving support  拖拽移动必要条件1

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSLog(@"%s section %zd row %zd",__FUNCTION__,sourceIndexPath.section,sourceIndexPath.row);

}

#pragma mark - UITableViewDelegate

//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//
//}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"快捷栏";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

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

// Editing

// Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s section %zd row %zd",__FUNCTION__,indexPath.section,indexPath.row);
    if (indexPath.section == 1) {
       return UITableViewCellEditingStyleDelete;
    } else if(indexPath.section == 2) {
       return UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleNone;
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

// The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s section %zd row %zd",__FUNCTION__,indexPath.section,indexPath.row);

}
- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(nullable NSIndexPath *)indexPath {
    NSLog(@"%s section %zd row %zd",__FUNCTION__,indexPath.section,indexPath.row);
}

//MARK:- Action

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

- (void)editTable {
    [self.tableView setEditing:!self.tableView.editing animated:YES]; //拖拽移动必要条件3
}

@end
