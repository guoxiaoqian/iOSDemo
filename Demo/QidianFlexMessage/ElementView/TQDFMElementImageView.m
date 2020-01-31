//
//  TQDFMElementImageView.m
//  QQMSFContact
//
//  Created by gavinxqguo on 18/11/20.
//
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "TQDFMElementImageView.h"
#import "TQDFMElementImage.h"

@interface TQDFMElementImageView () //<QQChatImageMetaInfoObserver>

@property (nonatomic, strong) UIImageView *imageView;

//@property (nonatomic, strong) QQChatImageMetaInfo *metaInfo;
@property (nonatomic, strong) NSString *coverUrl;
@property (nonatomic, strong) UIImage *imageFromUrl;

@end

@implementation TQDFMElementImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        _imageView.userInteractionEnabled = YES;
        [self addSubview:_imageView];
    }
    return self;
}

//- (void)dealloc {
//    CZ_RemoveObjFromDeftNotiCenterOnly(self);
//}

#pragma mark - Special Layout & Render

+ (CGSize)layoutSpecialQDFMElement:(TQDFMElementImage *)baseMsg withMaxSize:(CGSize)maxSize {
    
    CGSize maxContentSize = [baseMsg getMaxContentSizeWithMaxSize:maxSize];
    CGSize contentSize = maxContentSize;
    
    // STEP1: 测量图片
    if (baseMsg.isWidthSure == NO && baseMsg.isHeightSure == NO) {
        // 可由本地素材填充大小
        UIImage* localImage = [baseMsg getLocalImage];
        if (localImage && baseMsg.src.length <= 0) {
            contentSize = localImage.size;
        }
    }
    
    // STEP2: 布局图片
    CGPoint contentOrigin = [baseMsg getContentOriginWithContentSize:contentSize maxSize:maxSize];
    baseMsg.imageFrame = CGRectMake(contentOrigin.x, contentOrigin.y, contentSize.width, contentSize.height);
    
    // STEP3: 处理自身未确定的宽和高（Wrap）
    [baseMsg adjustSizeWithWrappedContentSize:contentSize];
    
    return baseMsg.layoutFrame.size;
}

- (void)renderSpecialQDFMElement:(TQDFMElementImage *)baseMsg {
    
    //调整图片frame
    _imageView.frame = baseMsg.imageFrame;
    
    // 取本地图片
    UIImage* localImage = [baseMsg getLocalImage];
    [self setCoverImage:localImage];
    
    // 取网络图片
    if(baseMsg.src.length){
        [self setCoverUrl:baseMsg.src];
    }
}

#pragma mark - Private

- (void)setCoverImage:(UIImage *)coverImage {
    [_imageView setImage:coverImage];
}

- (void)setCoverUrl:(NSString *)url {
    if ([_coverUrl isEqualToString:url] == NO) {
        
        //清理之前下载的结果
        _coverUrl = url;
        _imageFromUrl = nil;
//        CZ_RemoveObjFromDeftNotiCenter(self, QQImageDownloadWithUrlNotification, nil);
//
//        if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
//            //判断当前的网络及网络为非wifi时用户设置是否在非wifi下下载图片
//            BOOL bWillDownload = [g_var_QQAppSetting FlowAvailable];
//
//            NSDictionary *exInfo = nil;
//            id<TQDFMMessageModel> msgRef = ((TQDFMElementImage*)self.baseMsg).layoutContext.msgModel;
//            if (msgRef != nil) {
//                exInfo = @{@"msg" : msgRef, @"callerSource" : @"xml"/*表示从结构化消息调过去下载*/,@"size":NSStringFromCGSize(self.imageView.frame.size)};
//            }
//
//            _metaInfo = [[QQImageLoader instance] loadChatImageWithUrl:_coverUrl willDownload:bWillDownload andExInfo:exInfo];
//            _metaInfo.maxSize = self.imageView.frame.size;
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                UIImage *coverImage = [_metaInfo getClipOrScaleImage20PercentOffsetY];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (coverImage) {
//                        _imageFromUrl = coverImage;
//                        [self setCoverImage:coverImage];
//                    } else {
//                        // 没图片并且会下载图片时增加监听
//                        if (bWillDownload) {
//                            CZ_AddObj2DeftNotiCenter(self, @selector(onImageDownloadResult:), QQImageDownloadWithUrlNotification, nil);
//                        }
//                    }
//                });
//            });
//        }
        
        if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
            __weak typeof(self) weakSelf = self;
            [[TQDFMPlatformBridge sharedInstance] loadImageAsyncWithUrl:url complete:^(UIImage * _Nonnull image, NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.imageFromUrl = image;
                    [weakSelf setCoverImage:image];
                });
            }];
        }
        
    } else {
        
        // 复用之前下载的网络图片
        if (_imageFromUrl) {
            [self setCoverImage:_imageFromUrl];
        }
    }
}

//- (void)onImageDownloadResult:(NSNotification*)notification {
//    NSDictionary* dic = notification.userInfo;
//    BOOL result = [CZ_DicGetValueForKey(dic, @"result") boolValue];
//    NSString* url = CZ_DicGetValueForKey(dic, @"url");
//    QQChatImageMetaInfo* metaInfo = CZ_DicGetValueForKey(dic,@"metaInfo");
//
//    if ([url isEqualToString:_coverUrl]) {
//        if (result) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                UIImage *coverImage = [metaInfo getClipOrScaleImage20PercentOffsetY];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (coverImage) {
//                        _imageFromUrl = coverImage;
//                        [self setCoverImage:coverImage];
//                    }
//                    // 移除监听
//                    CZ_RemoveObjFromDeftNotiCenter(self, QQImageDownloadWithUrlNotification, nil);
//                });
//            });
//        }
//    }
//}

@end
