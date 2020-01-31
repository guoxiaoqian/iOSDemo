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

- (BOOL)isFMSender;
- (NSString*)getFMXMLContent;
- (NSString*)getFMUIStatus; //支持UI状态切换
- (TQDFMMessageLoadStatus)getFMLoadStatus; //加载中/加载失败

@end

@protocol TQDFMMessageCell <NSObject>

- (UIView*)dequeueReusableElementViewWithIdentifier:(NSString*)identifier;

@end


@protocol TQDFMPlatformBridgeDelegate <NSObject>

- (void)onFMLog:(NSString*)logStr;

- (void)onFMLoadImageAsyncWithUrl:(NSString*)url complete:(void(^)(UIImage* image, NSError* error))complete;
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

//MARK: 网络下载/缓存

- (void)loadImageAsyncWithUrl:(NSString*)url complete:(void(^)(UIImage* image, NSError* error))complete;

- (uint64_t)getNowTimestamp;
- (UIImage*)getBundleImageWithPath:(NSString*)path;

@end

NS_ASSUME_NONNULL_END
