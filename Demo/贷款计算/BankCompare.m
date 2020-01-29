//
//  BankCompare.m
//  Demo
//
//  Created by 郭晓倩 on 2019/8/25.
//  Copyright © 2019 郭晓倩. All rights reserved.
//

#import "BankCompare.h"

@interface BankCompare ()

@property (strong,nonatomic) UITextField* totalField;
@property (strong,nonatomic) UITextField* yearsField;

@property (strong,nonatomic) UILabel* totalBenifitLabel;
@property (strong,nonatomic) UITextView* monthBenifitTextView;


@end

@implementation BankCompare

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel* totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 20, 20)];
    totalLabel.text = @"总额/万";
    [totalLabel sizeToFit];
    
    UILabel* yearsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(totalLabel.frame) + 10, totalLabel.frame.size.width, totalLabel.frame.size.height)];
    yearsLabel.text = @"时长/年";
    [yearsLabel sizeToFit];

    self.totalField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(totalLabel.frame) + 10, CGRectGetMinY(totalLabel.frame), 200, 30)];
    self.yearsField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.totalField.frame),CGRectGetMinY(yearsLabel.frame), self.totalField.frame.size.width, self.totalField.frame.size.height)];

    UIButton* aliPayBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.totalField.frame) + 10, self.totalField.frame.origin.y, 40, 40)];
    [aliPayBtn setBackgroundColor:[UIColor blueColor]];
    [aliPayBtn setTitle:@"借呗" forState:UIControlStateNormal];
    aliPayBtn.tag = 1;
    [aliPayBtn addTarget:self action:@selector(clickPayBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* juyidaiBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(aliPayBtn.frame) + 10, CGRectGetMinY(aliPayBtn.frame), aliPayBtn.frame.size.width, aliPayBtn.frame.size.height)];
    [aliPayBtn setTitle:@"居逸贷" forState:UIControlStateNormal];
    [juyidaiBtn setBackgroundColor:[UIColor yellowColor]];
    juyidaiBtn.tag = 2;
    [juyidaiBtn addTarget:self action:@selector(clickPayBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    self.totalBenifitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.yearsField.frame) + 20, kScreenWidth, 30)];
    
    self.monthBenifitTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.totalBenifitLabel.frame), kScreenWidth, 400)];
    
    [self.view addSubview:totalLabel];
    [self.view addSubview:yearsLabel];
    [self.view addSubview:self.totalField];
    [self.view addSubview:self.yearsField];
    
    [self.view addSubview:aliPayBtn];
    [self.view addSubview:juyidaiBtn];

    [self.view addSubview:self.totalBenifitLabel];
    [self.view addSubview:self.monthBenifitTextView];

}

#pragma mark - AliPay

- (void)aliPayWithTotal:(float)total years:(int)years {
    float benifitRatio = 2.0 / 10000;
    float payPerMonth = total / (years * 12);
    float leftTotal = total;
    float totalBenifit = 0;
    
    NSMutableString* text = [NSMutableString new];
    for (int month = 1; month <= years * 12; month ++) {
        float benifit = leftTotal * benifitRatio * 31;
        NSString* str = [NSString stringWithFormat:@"month: %d pay: %.2f benifit: %.2f\n",month,payPerMonth+benifit,benifit];
        
        [text appendString:str];
        
        leftTotal -= payPerMonth;
        totalBenifit += benifit;
    }
    
    self.monthBenifitTextView.text = text;
    self.totalBenifitLabel.text = [NSString stringWithFormat:@"总利息 %.2f",totalBenifit];
}

- (void)juyidaiWithTotal:(float)total years:(int)years {
    
//    1年（12期）利率    3.4%
//    2年（24期）利率    7.09%
//    3年（36期）利率    10.64%
//    4年（48期）利率    14.01%
//    5年（60期）利率    17.44%

    NSDictionary* feeDic = @{
                           @(1):@(3.4),
                           @(2):@(7.09),
                           @(3):@(10.64),
                           @(4):@(14.01),
                           @(5):@(17.44),
                           };
    
    float benifitRatio = [feeDic[@(years)] floatValue] / 100;
    float totalBenifit = total * benifitRatio;
    float payPerMonth = total / (years * 12);
    float benifitPerMonth = totalBenifit / (years * 12);
    
    NSString* str = [NSString stringWithFormat:@"pay: %.2f contain benifit: %.2f\n",payPerMonth+benifitPerMonth,benifitPerMonth];

    
    self.monthBenifitTextView.text = str;
    self.totalBenifitLabel.text = [NSString stringWithFormat:@"总利息 %.2f",totalBenifit];
}


- (void)clickPayBtn:(UIButton*)btn {
    float total = [self.totalField.text floatValue];
    float years = [self.yearsField.text floatValue];
    
    total = total * 10000;
    
    if (years < 1 || years > 5) {
        return;
    }
    if (btn.tag == 1) {
        [self aliPayWithTotal:total years:years];
    } else if(btn.tag == 2) {
        [self juyidaiWithTotal:total years:years];
    }
}

@end
