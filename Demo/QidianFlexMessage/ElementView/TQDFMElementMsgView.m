//
//  TQDFMElementMsgView.m
//  Demo
//
//  Created by 郭晓倩 on 2020/1/31.
//  Copyright © 2020 郭晓倩. All rights reserved.
//

#import "TQDFMElementMsgView.h"
#import "TQDFMElementBase.h"

@implementation TQDFMElementMsgView

+ (CGSize)layoutSpecialQDFMElement:(TQDFMElementMsg *)baseMsg withMaxSize:(CGSize)maxSize {
    CGFloat consumedHeight = 0;
    CGFloat consumedWidth = 0;
    for (TQDFMElementBase* childElement in baseMsg.subElements) {
        CGSize fitSize = [TQDFMElementBaseView layoutQDFMElement:childElement withMaxSize:maxSize];
        
        // 直接排版子元素
        [childElement setLayoutFrameY: consumedHeight];

        consumedHeight += fitSize.height;
        consumedWidth = MAX(consumedWidth,fitSize.width);
    }
    CGSize contentSize = CGSizeMake(consumedWidth,consumedHeight);
    
    // STEP3: 处理自身未确定的宽和高（Wrap）
    [baseMsg adjustSizeWithWrappedContentSize:contentSize];
    
    return baseMsg.layoutFrame.size;

}

@end
