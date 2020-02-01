//
//  TQDFMPlatformBridge.m
//  IMWebSocketDemo
//
//  Created by 郭晓倩 on 2020/1/31.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TQDFMPlatformBridge.h"
#import <UIKit/UIKit.h>

#define TQDFM_ELEMENT_DEFAULT_FONTSIZE   14

@implementation TQDFMPlatformBridge

+ (instancetype)sharedInstance
{
    static TQDFMPlatformBridge *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TQDFMPlatformBridge alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)log:(NSString*)logStr {
    if ([self.delegate respondsToSelector:@selector(fm_log:)]) {
        [self.delegate fm_log:logStr];
    } else {
        NSLog(@"FMLog: %@",logStr);
    }
}

+(int)getScreenWidth
{
    static int s_scrWidth = 0;
    if (s_scrWidth == 0){
        UIScreen* screen = [UIScreen mainScreen];
        CGRect screenFrame = screen.bounds;
        s_scrWidth = MIN(screenFrame.size.width, screenFrame.size.height);
        
        //解决在ipad中app启动时[UIScreen mainScreen].CZ_B_SizeW于768px的问题
        if (s_scrWidth >= 768) {
            s_scrWidth = 320 * (s_scrWidth / 768.0f);
        }
    }
    
    return s_scrWidth;
}

//以iPhone6屏幕宽度为基准
+ (CGFloat)fitScreenWidthBy6:(CGFloat)value
{
    return (value/375.0f)* [self getScreenWidth];
}

//设计不支持屏幕比例缩放字号
+ (CGFloat)fontfitScreenWidthBy6:(CGFloat)value
{//字号沿用之前逻辑
    return (value/375.0f)*[self getScreenWidth];
}

- (CGFloat)widthFromPixel:(CGFloat)pixel {
    return [self.class fitScreenWidthBy6:pixel / 2.0];
}
- (CGFloat)heightFromPixel:(CGFloat)pixel {
    return [self.class fitScreenWidthBy6:pixel / 2.0];
}
- (CGFloat)fontSizeFromPixel:(CGFloat)pixel {
    return [self.class fontfitScreenWidthBy6: pixel / 2.0];
}

- (NSString*)themeColorHexStr {
#if TQDFM_QIDIAN
    return @"#FF0067ED";
#else
    return @"#FF00A5E0";
#endif
}

- (CGFloat)defaultFontSize {
    return [self.class fontfitScreenWidthBy6: TQDFM_ELEMENT_DEFAULT_FONTSIZE];
}

- (UIColor*)defaultFontColor {
    return [UIColor blackColor];
}

- (void)loadImageAsyncWithUrl:(NSString*)url complete:(void(^)(UIImage* image, NSError* error))complete {
    if ([self.delegate respondsToSelector:@selector(fm_loadImageAsyncWithUrl:complete:)]) {
        [self.delegate fm_loadImageAsyncWithUrl:url complete:complete];
    }
}

- (uint64_t)getNowTimestamp {
    //TODO-GAVIN:(CZ_getCurrentLocalTime() + CZ_GetServerTimeDiff());
    return [[NSDate date] timeIntervalSince1970];
}

- (UIImage*)getBundleImageWithPath:(NSString*)path {
    //TODO-GAVIN:;
    return [UIImage imageNamed:path];
}

@end


