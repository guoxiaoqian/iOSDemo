//
//  TQDFMLayoutTree.m
//  QQ
//
//  Created by 郭晓倩 on 2019/1/12.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "TQDFMLayoutTree.h"
#import "TQDFMXMLParser.h"
#import "TQDFMElementBase.h"

@interface TQDFMLayoutTree ()

@property (strong,nonatomic) id<TQDFMMessageModel> msgModel;

@end

@implementation TQDFMLayoutTree

- (instancetype)initWithMessageModel:(id<TQDFMMessageModel>)messageModel elementTree:(TQDFMElementMsg*)elementTree {
    if (self = [super init]) {
        self.msgModel = messageModel;
        NSString* content = nil;
        BOOL hasXmlContent = elementTree != nil;
        TQDFMLayoutContext* layoutContext = nil;
        
        if (elementTree == nil) {
            
            content = [messageModel getFMXMLContent];
            
            hasXmlContent = content.length > 0;
            
            // 首次加载时，确保XML解析流程能走通
            if (content.length == 0) {
                content = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<msg flag=\"37\" brief=\"收到一条新消息\"></msg>";
            }
            
            if (hasXmlContent) {
                NSLog(@"Serialize LengthXML %d",(int)[content dataUsingEncoding:NSUTF8StringEncoding].length);
                TQDFM_TIME_BEGIN(@"Serialize ParseXML");
            }
            
            elementTree = [[TQDFMXMLParser new] parseByString:content];
            
            if (hasXmlContent) {
                TQDFM_TIME_END(@"Serialize ParseXML");
            }
        }
        
        if (elementTree) {
            // 布局上下文
            if (layoutContext == nil) {
                layoutContext = [TQDFMLayoutContext new];
            }
            layoutContext.msgModel = messageModel;
            
            // 辅助状态: 优先用ExInfo里存储的status,其次是结构化消息初始的status
            layoutContext.status = elementTree.attributes[@"status"];
            //            NSString* uiStatus = [messageModel.exInfo getQidianFlexMessageUIStatus];
            NSString* uiStatus = [messageModel getFMUIStatus];
            
            if (uiStatus.length > 0) {
                layoutContext.status = uiStatus;
            }
            
            // 过期状态优先级最高
            if (elementTree.attributes[@"expireTime"] && elementTree.attributes[@"expireStatus"]) {
                uint64_t  nowTime =  [[TQDFMPlatformBridge sharedInstance] getNowTimestamp];
                uint64_t  expireTime = [elementTree.attributes[@"expireTime"] longLongValue];
                if(nowTime >= expireTime) {
                    layoutContext.isExpired = YES;
                    layoutContext.status = elementTree.attributes[@"expireStatus"];
                }
            }
            
            // 构建索引等信息
            [[self class] adjustElementTree:elementTree layoutContext:layoutContext];
            
            // 加载中和加载失败效果
            //            LongMsg_Kind downloadState = [messageModel.exInfo getQidianFlexMessageState];
            //            if (downloadState == LongMsg_No_Content || downloadState == LongMsg_Content_Fail) {
            //                QQLongMsgHolder *holder  = [QQLongMsgHolder new];
            //                holder.holderType = downloadState;
            //                elementTree.subElements = @[holder];
            //                layoutContext.isHolder = YES;
            //            } else {
            //                layoutContext.isHolder = NO;
            //            }
            
            TQDFMMessageLoadStatus loadStaus = [messageModel getFMLoadStatus];
            if (loadStaus == TQDFMMessageLoadStatus_NotLoad || loadStaus == TQDFMMessageLoadStatus_Fail) {
                TQDFMElementLoadingHolder *holder  = [TQDFMElementLoadingHolder new];
                holder.loadStatus = loadStaus;
                elementTree.subElements = [NSMutableArray arrayWithObject:holder];
                layoutContext.isHolder = YES;
                
            }
            
        }
        
        self.elementTree = elementTree;
        self.layoutContext = layoutContext;
    }
    return self;
}

// 调整整体结构，包括索引、父元素、布局上下文
+ (void)adjustElementTree:(TQDFMElementBase*)baseMsg layoutContext:(TQDFMLayoutContext*)layoutContext{
    if (!baseMsg.elemIndex) {
        baseMsg.elemIndex = @"0";
    }
    NSMutableArray* hiddenChildArray = [NSMutableArray new];
    for (NSUInteger itemIndex = 0; itemIndex < baseMsg.subElements.count; ++itemIndex) {
        TQDFMElementBase* element = baseMsg.subElements[itemIndex];
        
        // 添加索引，方便定位节点
        if(!element.elemIndex) {
            element.elemIndex = [NSString stringWithFormat:@"%@.%zd",baseMsg.elemIndex,itemIndex];
        }
        
        if ([element isKindOfClass:[TQDFMElementBase class]]) {
            ((TQDFMElementBase*)element).layoutContext = layoutContext;
            ((TQDFMElementBase*)element).parentElement = baseMsg;
            
            // 记录隐藏的元素，不再参加构建
            if ([(TQDFMElementBase*)element isHiddenForever]) {
                [hiddenChildArray addObject:element];
                continue;
            }
        }
        
        //递归下去
        [self adjustElementTree:element layoutContext:layoutContext];
        
        //通知节点当前子树已经构建完成
        if ([element isKindOfClass:[TQDFMElementBase class]]) {
            [((TQDFMElementBase*)element) elementTreeDidBuild];
        }
    }
    
    // 移除隐藏的子节点
    if (hiddenChildArray.count) {
        NSMutableArray* subElements = [baseMsg.subElements mutableCopy];
        [subElements removeObjectsInArray:hiddenChildArray];
        baseMsg.subElements = subElements;
    }
}

@end
