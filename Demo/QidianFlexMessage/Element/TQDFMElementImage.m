//
//  TQDFMElementImage.m
//  QQ
//
//  Created by 郭晓倩 on 2018/11/24.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "TQDFMElementImage.h"

@implementation TQDFMElementImage

- (instancetype)initWithElementName:(NSString *)elementName {
    if (self = [super initWithElementName:elementName]) {
        _imageFrame = CGRectZero;
    }
    return self;
}

+ (UIImage*)getLocalImageWithIconName:(NSString*)iconNameStr {
    //TODO-GAVIN: 不建议使用本地素材    
    static NSDictionary* imagePathDic = nil;
    if (imagePathDic == nil) {
        imagePathDic = @{
                         @"arrow_right":@"QidianFlexMessage/qidian_flex_arrow_right.png",
                         @"arrow_down":@"QidianFlexMessage/qidian_flex_arrow_down.png",
                         @"user_default":@"user_avatar_default.png",
                         @"pic_default":@"aio_image_default.png",
                         };
    }

    NSArray* iconNameArray = [iconNameStr componentsSeparatedByString:@"|"];
    UIImage* localImage = nil;
    for (NSString* iconName in iconNameArray) {

        // 从icon映射中找
        NSString* imagePath = imagePathDic[iconName];
        if (imagePath) {
            localImage = [[TQDFMPlatformBridge sharedInstance] getBundleImageWithPath: imagePath];
            if (localImage) {
                break;
            }
        }

        // 从指定目录里找
        imagePath =  [NSString stringWithFormat:@"QidianFlexMessage/%@.png",iconName];
        localImage = [[TQDFMPlatformBridge sharedInstance] getBundleImageWithPath:imagePath];
        if (localImage) {
            break;
        }

        // 全局查找
        imagePath = [NSString stringWithFormat:@"%@.png",iconName];
        localImage = [[TQDFMPlatformBridge sharedInstance] getBundleImageWithPath:imagePath];
        if (localImage) {
            break;
        }
    }
    
    return localImage;
}

- (UIImage*)getLocalImage {
    return [[self class] getLocalImageWithIconName:self.icon];
}

@end
