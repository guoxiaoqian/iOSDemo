//
//  FlexMessageVC.m
//  Demo
//
//  Created by 郭晓倩 on 2020/1/31.
//  Copyright © 2020 郭晓倩. All rights reserved.
//

#import "FlexMessageVC.h"
#import "TQDFMElementBase.h"
#import "TQDFMElementBaseView.h"
#import "TQDFMLayoutTree.h"
#import "TQDFMEvent.h"

@interface TestMessageModel : NSObject <TQDFMMessageDataSource>

@end

@implementation TestMessageModel

- (BOOL)fm_isSelfSender {
    return YES;
}

- (NSString*)fm_getXMLContent {
    NSURL* xmlURL = [[NSBundle mainBundle] URLForResource:@"Demo" withExtension:@"xml"];
    NSData* data = [NSData dataWithContentsOfURL:xmlURL];
    NSString* xmlContent = [[NSString alloc] initWithCString:data.bytes encoding:NSUTF8StringEncoding];
    return xmlContent;
}

- (NSString*)fm_getUIStatus {
    return nil;
}

- (TQDFMMessageLoadStatus)fm_getLoadStatus {
    return TQDFMMessageLoadStatus_Success;
}

@end

@interface FlexMessageVC () <TQDFMMessageUIDelegate>

@property (strong,nonatomic) TestMessageModel* msgModel;
@property (strong,nonatomic) TQDFMLayoutTree* layoutTree;
@property (strong,nonatomic) TQDFMElementBaseView* flexMsgView;


@end

@implementation FlexMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor greenColor];
    
    //构建元素树
    self.msgModel = [TestMessageModel new];
    self.layoutTree = [[TQDFMLayoutTree alloc] initWithMessageModel:self.msgModel elementTree:nil];
    self.layoutTree.layoutContext.uiDelegate = self;
  
    [self fm_reLayout];
}

- (void)fm_reLayout {
    if (self.flexMsgView) {
        [self.flexMsgView removeFromSuperview];
        self.flexMsgView = nil;
    }
    
    //开始布局
    TQDFMElementBase* elementTree = self.layoutTree.elementTree;
    CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,MAXFLOAT);
    CGSize fitSize = [TQDFMElementBaseView layoutQDFMElement:elementTree withMaxSize:maxSize];
    
    //开始渲染
    CGRect rectForMsg = CGRectMake(0,100,fitSize.width,fitSize.height);
    TQDFMElementBaseView* msgView = [TQDFMElementBaseView createQDFMElementView:elementTree withFrame:rectForMsg];
    [msgView renderQDFMElement:elementTree];
    
    self.flexMsgView = msgView;
    [self.view addSubview:msgView];
}

//事件处理
- (void)fm_elementView:(TQDFMElementBaseView *)elementView didAction:(TQDFMEvent*)event {
    if ([event.action isEqualToString:@"svrCmd"]) {
        //修改状态 & 重新布局
        self.layoutTree.layoutContext.status = @"3";
        self.layoutTree.layoutContext.isDirty = YES;
        
        [self fm_reLayout];
    }
}

@end
