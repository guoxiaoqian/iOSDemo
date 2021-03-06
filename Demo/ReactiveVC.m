//
//  ReactiveVC.m
//  Demo
//
//  Created by 郭晓倩 on 2018/10/13.
//  Copyright © 2018年 郭晓倩. All rights reserved.
//

#import "ReactiveVC.h"
#import "ReactiveCocoa.h"

@interface ReactiveVC ()

@end

@implementation ReactiveVC

- (RACSignal*)signalWithTag:(NSString*)tag {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"%@ next",tag);
        [subscriber sendNext:tag];
        NSLog(@"%@ completed",tag);
        [subscriber sendCompleted];
        return nil;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//
//    RACSignal* signalA = [self signalWithTag:@"A"];
//    RACSignal* signalB = [self signalWithTag:@"B"];
//
//    [[RACSignal merge:@[signalA,signalB]] subscribeCompleted:^{
//        NSLog(@"all completed");
//    }];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
//    [self testIconFont];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 字体矢量图

- (void)testIconFont {

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 300, 40)];
    label.backgroundColor = [UIColor greenColor];
    
    label.font = [UIFont fontWithName:@"iconfont" size:35];
//   &#xe62f 转换 \U0000e618  &#xe614;  &#xe618;
    label.text = @"\U0000e614哈哈哈\U0000e618";
    
    label.textColor = [UIColor redColor]; //改变字体颜色就是改变图片颜色
    
    [self.view addSubview:label];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
