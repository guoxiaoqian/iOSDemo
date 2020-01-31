//
//  TQDFMElementButton.m
//  QQ
//
//  Created by 郭晓倩 on 2018/11/26.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "TQDFMElementButton.h"
#import "TQDFMPlatformBridge.h"

@implementation TQDFMElementButton

-(id)initWithElementName:(NSString *)elementName {
    if (self = [super initWithElementName:elementName]) {
        self.gravityHorizontal = TQDFM_GRAVITY_CENTER_HORIZONTAL;
        self.gravityVertical = TQDFM_GRAVITY_CENTER_VERTICAL;
        self.color = [[TQDFMPlatformBridge sharedInstance] themeColorHexStr];
    }
    return self;
}

@end
