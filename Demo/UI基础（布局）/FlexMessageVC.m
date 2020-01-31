//
//  FlexMessageVC.m
//  Demo
//
//  Created by 郭晓倩 on 2020/1/31.
//  Copyright © 2020 郭晓倩. All rights reserved.
//

#import "FlexMessageVC.h"
#import "TQDFMElementBase.h"
#import "TQDFMXMLParser.h"
#import "TQDFMElementBaseView.h"
#import "TQDFMLayoutTree.h"

@interface TestMessageModel : NSObject <TQDFMMessageModel>

@end

@implementation TestMessageModel

- (BOOL)isFMSender {
    return YES;
}
- (NSString*)getFMXMLContent {
    NSURL* xmlURL = [[NSBundle mainBundle] URLForResource:@"Demo" withExtension:@"xml"];
    NSData* data = [NSData dataWithContentsOfURL:xmlURL];
    NSString* xmlContent = [[NSString alloc] initWithCString:data.bytes encoding:NSUTF8StringEncoding];
    return xmlContent;
}

- (NSString*)getFMUIStatus {
    return @"1";
}

- (TQDFMMessageLoadStatus)getFMLoadStatus {
    return TQDFMMessageLoadStatus_Success;
}

@end

@interface FlexMessageVC ()

@property (strong,nonatomic) TestMessageModel* msgModel;
@property (strong,nonatomic) TQDFMLayoutTree* layoutTree;
@property (strong,nonatomic) TQDFMElementMsg* flexMsg;

@end

@implementation FlexMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //构建元素树
    self.msgModel = [TestMessageModel new];
    self.layoutTree = [[TQDFMLayoutTree alloc] initWithMessageModel:self.msgModel elementTree:nil];
    self.flexMsg = self.layoutTree.elementTree;
    
    //开始布局
    CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,MAXFLOAT);
    CGSize fitSize = [TQDFMElementBaseView layoutQDFMElement:self.flexMsg withMaxSize:maxSize];
    
    //开始渲染
    CGRect rectForMsg = CGRectMake(0,0,fitSize.width,fitSize.height);
    TQDFMElementBaseView* msgView = [TQDFMElementBaseView createQDFMElementView:self.flexMsg withFrame:rectForMsg];
    [msgView renderQDFMElement:self.flexMsg];
    
    [self.view addSubview:msgView];
    
}


@end
