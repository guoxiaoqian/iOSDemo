//
//  TQDFMElementButtonView.m
//  QQ
//
//  Created by 郭晓倩 on 2018/11/21.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


#import "TQDFMElementButtonView.h"
#import "TQDFMElementButton.h"

@interface TQDFMElementButtonView ()

@end

@implementation TQDFMElementButtonView

- (void)drawRect:(CGRect)rect {
    UIImage* bgImage = nil;
    if (self.highlighted == YES) {
        bgImage = [[TQDFMPlatformBridge sharedInstance] getBundleImageWithPath:@"bubble_below_pressed.png"];
        
        // 这里绘制区域修正，是因为使用了公共账号的资源，图片有很长的透明边缘
        CGRect drawRect = CGRectMake(-16, 0, self.frame.size.width + 32, self.frame.size.height + 10);
        bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width / 2 topCapHeight:bgImage.size.height / 2];
        [bgImage drawInRect:drawRect];
    }
}

- (void)prepareForReuse {
    if (self.highlighted) {
        [super prepareForReuse];
        [self setNeedsDisplay];
    } else {
        [super prepareForReuse];
    }
}

- (void)handleHighlited:(BOOL)highlited {
    [super handleHighlited:highlited];
    //TODO-GAVIN: 点击高亮处理
    if (highlited) {
        self.backgroundColor = [UIColor grayColor];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
