//
//  TQDFMElementFoldView.m
//  QQ
//
//  Created by 郭晓倩 on 2018/11/21.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


#import "TQDFMElementFoldView.h"
#import "TQDFMElementBase.h"
#import "TQDFMEvent.h"

@implementation TQDFMElementFoldView

+ (CGSize)layoutSpecialQDFMElement:(TQDFMElementFold *)baseMsg withMaxSize:(CGSize)maxSize {
    
    int expand = baseMsg.expand.intValue;
    if (expand != 0 && expand != 1) {
        TQDFM_INFOP_ASSERT_ELEMENT(baseMsg, @"expand invalid");
        expand = 0;
    }
    
    if (baseMsg.subElements.count < 2) {
        TQDFM_INFOP_ASSERT_ELEMENT(baseMsg, @"fold child num invalid");
        if (baseMsg.subElements.count == 1) {
            expand = 0;
        } else {
            // 没有子元素时，直接返回
            [baseMsg setLayoutFrameForSure:CGRectZero];
            return baseMsg.layoutFrame.size;
        }
    }
    
    CGSize maxContentSize = [baseMsg getMaxContentSizeWithMaxSize:maxSize];

    // 测量显示的子元素
    TQDFMElementBase* elementToShow = baseMsg.subElements[expand];
    CGSize contentSize = [self layoutQDFMElement:elementToShow withMaxSize:maxContentSize];

    // 不显示的元素大小置为零
    for (TQDFMElementBase* element in baseMsg.subElements) {
        if (element != elementToShow) {
            [element setLayoutFrameForSure:CGRectZero];
        }
    }
    
    // 布局显示的子元素
    CGPoint contentOrigin = [baseMsg getContentOriginWithContentSize:contentSize maxSize:maxSize];
    [elementToShow setLayoutFrameForSure:CGRectMake(contentOrigin.x, contentOrigin.y, contentSize.width, contentSize.height)];
    
    // 设置自身大小
    [baseMsg adjustSizeWithWrappedContentSize:contentSize];
    
    return baseMsg.layoutFrame.size;
}

@end
