//
//  ViewController.m
//  UNODemo
//
//  Created by gavinxqguo on 2021/2/7.
//

#import "BaseViewController.h"
#import <mach/mach.h>

#define ENABLE_GTEST 0

#if ENABLE_GTEST
#   include "gtest/gtest.h"
#endif


@implementation EntryModel

+(EntryModel*)modelWithClass:(Class)class_{
    EntryModel* model = [EntryModel new];
    model.name = NSStringFromClass(class_);
    model.targetVCClass = class_;
    return model;
}

+(EntryModel*)modelWithName:(NSString*)name class:(Class)class_{
    EntryModel* model = [EntryModel new];
    model.name = name;
    model.targetVCClass = class_;
    return model;
}

@end

@implementation ClickModel

+(ClickModel*)modelWithSelector:(SEL)selector{
    ClickModel* model = [ClickModel new];
    model.name = NSStringFromSelector(selector);
    model.targetSelector = selector;
    return model;
}

+ (ClickModel *)modelWithGTestFilter:(NSString*)filter {
    ClickModel* model = [ClickModel new];
    model.name = filter;
    model.gtestFilter = filter;
    return model;
}


@end


@interface BaseViewController () <UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) UITableView* tableView;

@property (strong,nonatomic) NSMutableDictionary* memoryDic;
@property (strong,nonatomic) NSMutableDictionary* timeDic;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.dataSource = [NSMutableArray arrayWithObjects:nil];
    
    self.memoryDic = [NSMutableDictionary dictionary];
    self.timeDic = [NSMutableDictionary dictionary];
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
    if ([model isKindOfClass:[EntryModel class]]) {
        UIViewController* vc = [[model.targetVCClass alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if([model isKindOfClass:[ClickModel class]]) {
        SEL selector = ((ClickModel*)model).targetSelector;
        if (selector) {
            if ([self respondsToSelector:selector]) {
                [self performSelector:selector];
            }
        } else if(((ClickModel*)model).gtestFilter.length) {
            [self runGTest:[((ClickModel*)model).gtestFilter UTF8String]];
        }
    }
}

- (void)runGTest:(const char*)filter {
#if ENABLE_GTEST
    testing::GTEST_FLAG(filter) = filter; //执行test case过滤
    testing::InitGoogleTest();
    RUN_ALL_TESTS();
#endif
}

//MARK: - Tool

- (double)memoryPhysFootprint {
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t ret = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t)&vmInfo, &count);
    if (ret != KERN_SUCCESS) {
        return 0;
    }
    return vmInfo.phys_footprint /1024.0/1024.0;
}

- (void)logTimeWithEventBegin:(NSString*)event {
    CFTimeInterval time = CACurrentMediaTime();
    self.timeDic[event] = @(time);
}

- (void)logTimeWithEventEnd:(NSString*)event {
    if (!self.timeDic[event]) {
        return;
    }
    CFTimeInterval beginTime = [self.timeDic[event] doubleValue];
    CFTimeInterval endTime = CACurrentMediaTime();
    NSLog(@"[TimeMonitor] %@ costTime=%.2fs",event,endTime-beginTime);
}

- (void)logMemoryWithEventBegin:(NSString*)event {
    double memory = [self memoryPhysFootprint];
    self.memoryDic[event] = @(memory);
}

- (void)logMemoryWithEventEnd:(NSString*)event {
    if (!self.memoryDic[event]) {
        return;
    }
    double beginMemory = [self.memoryDic[event] doubleValue];
    double endMemory = [self memoryPhysFootprint];
    NSLog(@"[TimeMonitor] %@ beginMemory=%.2fM endMemory=%.2fM cost=%.2fM",event,beginMemory,endMemory,endMemory-beginMemory);
}

@end
