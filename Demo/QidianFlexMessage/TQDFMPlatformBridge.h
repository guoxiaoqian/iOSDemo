//
//  TQDFMPlatformBridge.h
//  IMWebSocketDemo
//
//  Created by 郭晓倩 on 2020/1/31.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TQDFMMessageLoadStatus) {
    TQDFMMessageLoadStatus_NotLoad,
    TQDFMMessageLoadStatus_Success,
    TQDFMMessageLoadStatus_Fail,
};

@protocol TQDFMMessageModel <NSObject>

- (BOOL)fm_isSelfSender;
- (NSString*)fm_getXMLContent;
- (NSString*)fm_getUIStatus; //支持UI状态切换
- (TQDFMMessageLoadStatus)fm_getLoadStatus; //加载中/加载失败

@end

@class TQDFMElementBaseView;
@class TQDFMEvent;
@protocol TQDFMMessageCell <NSObject>

//视图刷新
- (void)fm_reLayout;

//视图复用
- (UIView*)fm_dequeueReusableElementViewWithIdentifier:(NSString*)identifier;

//事件处理
- (void)fm_elementView:(TQDFMElementBaseView *)elementView didAction:(TQDFMEvent*)event;

@end


@protocol TQDFMPlatformBridgeDelegate <NSObject>

- (void)fm_log:(NSString*)logStr;

- (void)fm_loadImageAsyncWithUrl:(NSString*)url complete:(void(^)(UIImage* image, NSError* error))complete;
@end

@interface TQDFMPlatformBridge : NSObject

@property (weak,nonatomic) id<TQDFMPlatformBridgeDelegate> delegate;

+ (instancetype)sharedInstance;

//MARK: 行为
- (void)log:(NSString*)logStr;

//MARK: 单位转换
- (CGFloat)widthFromPixel:(CGFloat)pixel;
- (CGFloat)heightFromPixel:(CGFloat)pixel;
- (CGFloat)fontSizeFromPixel:(CGFloat)pixel;

//MARK: 默认值
- (NSString*)themeColorHexStr;
- (CGFloat)defaultFontSize;
- (UIColor*)defaultFontColor;

//MARK: 网络下载
- (void)loadImageAsyncWithUrl:(NSString*)url complete:(void(^)(UIImage* image, NSError* error))complete;

//MARK: 加载系统资源
- (uint64_t)getNowTimestamp;
- (UIImage*)getBundleImageWithPath:(NSString*)path;

@end

NS_ASSUME_NONNULL_END
