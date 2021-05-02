//
//  SelfSizingVC.m
//  Demo
//
//  Created by gavinxqguo on 2020/6/17.
//  Copyright © 2020 郭晓倩. All rights reserved.
//

#import "SelfSizingVC.h"
#import "Masonry.h"

@interface SelfSizingContainerView : UIView

@property (strong) UILabel* label;

@end

@implementation SelfSizingContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.label = [[UILabel alloc] init];
        self.label.numberOfLines = 0;
        [self addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

//- (CGSize)intrinsicContentSize {
//    
//    return CGSizeMake([UIScreen mainScreen].bounds.size.width, arc4random_uniform(80) + 20);
//}

@end

@interface SelfSizingTableCell : UITableViewCell

@property (strong) SelfSizingContainerView* containerView;

@end

@implementation SelfSizingTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.containerView = [[SelfSizingContainerView alloc] init];
        self.containerView.backgroundColor = [UIColor colorWithRed:arc4random_uniform(100)/100.0 green:arc4random_uniform(100)/100.0 blue:arc4random_uniform(100)/100.0 alpha:1];
        [self.contentView addSubview:self.containerView];
        [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setData {
    static NSArray* strArray = nil;
   strArray = @[@"深咖啡多斯拉克代发酸辣粉索拉卡发电量咖啡店杀戮空间啊对方是离开问我问我问我未来就为了看电视了刻录机开电风扇记录发送的方式 水电费拉沙发到了发的是的方式来咖啡色打蜡辅导书富士达拉发大水拉德芳斯",
                @"是离开水电费鲁大师弗兰克大放送我我薇薇欧文哦奥拉夫萨拉飞洒拉德芳斯"];
    self.containerView.label.text = strArray[arc4random_uniform(2)];
}

@end



@interface SelfSizingVC ()

@end

@implementation SelfSizingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.showsVerticalScrollIndicator = YES;
    [self.tableView registerClass:[SelfSizingTableCell class] forCellReuseIdentifier:@"SelfSizingTableCell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelfSizingTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelfSizingTableCell" forIndexPath:indexPath];
    [cell setData];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"heightForRowAtIndexPath:%@",indexPath.description);
    return UITableViewAutomaticDimension;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
