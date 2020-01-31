//
//  TQDFMElementFrameView.m
//  QQ
//
//  Created by 郭晓倩 on 2018/11/21.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


#import "TQDFMElementContainerView.h"
#import "TQDFMElementBase.h"

@implementation TQDFMElementContainerView

+ (CGSize)layoutSpecialQDFMElement:(TQDFMElementContainer *)baseMsg withMaxSize:(CGSize)maxSize {
    
    //STEP1:测量子元素
    __block CGFloat maxWidthConsumedByChild = 0;
    __block CGFloat maxHeightConsumedByChild = 0;
    __block BOOL hasMeasuredChild = NO;
    CGFloat contentWidthRemained = maxSize.width - baseMsg.paddingLeft - baseMsg.paddingRight;
    CGFloat contentHeightRemained = maxSize.height - baseMsg.paddingTop - baseMsg.paddingBottom;
    NSMutableArray* visibleElements = [NSMutableArray new];
    NSMutableArray* visibleWidthMatchedElements = [NSMutableArray new];
    NSMutableArray* visibleHeightMatchedElements = [NSMutableArray new];
    NSMutableArray* visibleMeasurableElements = [NSMutableArray new];
    
    //第一次遍历：处理可见性，计算所有可见元素weight总和及已用宽度
    [self classifyChildernForElement:baseMsg
                     visibleElements:visibleElements
             visibleWeightedElements:nil
         visibleWidthMatchedElements:visibleWidthMatchedElements
        visibleHeightMatchedElements:visibleHeightMatchedElements
           visibleMeasurableElements:visibleMeasurableElements
                      childWeightSum:nil
                contentWidthConsumed:nil
                contentWidthRemained:contentWidthRemained
            maxHeightConsumedByChild:&maxHeightConsumedByChild
               contentHeightConsumed:nil
               contentHeightRemained:contentHeightRemained
             maxWidthConsumedByChild:&maxHeightConsumedByChild];
    
    //校验剩余宽高
    if (TQDFM_FLOAT_LESS_THAN_ZERO(contentWidthRemained)) {
        TQDFM_INFOP_ASSERT_ELEMENT(baseMsg, @"frame width not enough");
    }
    contentWidthRemained = MAX(0, contentWidthRemained);
    if (TQDFM_FLOAT_LESS_THAN_ZERO(contentHeightRemained)) {
        TQDFM_INFOP_ASSERT_ELEMENT(baseMsg, @"frame height not enough");
    }
    contentHeightRemained = MAX(0, contentHeightRemained);
    
    //测量单个子元素大小的block
    void (^measureChildBlock)(TQDFMElementBase *, CGFloat, CGFloat, NSString*) = ^(TQDFMElementBase * element,CGFloat maxWidthForChild, CGFloat maxHeightForChild,NSString* measureStep) {
        
        hasMeasuredChild = YES;
        
        [self measureSizeForChild:element
                 maxWidthForChild:maxWidthForChild
                maxHeightForChild:maxHeightForChild
         horizontalMarginConsumed:NO
           verticalMarginConsumed:NO
          maxWidthConsumedByChild:&maxWidthConsumedByChild
         maxHeightConsumedByChild:&maxHeightConsumedByChild];
    };
    
    //第二次遍历：计算宽非match/高非match的可见子元素的大小
    for (TQDFMElementBase * element in visibleMeasurableElements) {
        CGFloat maxWidthForChild = contentWidthRemained;
        CGFloat maxHeightForChild = contentHeightRemained;
        measureChildBlock(element,maxWidthForChild,maxHeightForChild, @"measure exact child");
    }
    
    //计算自身整体高度：高度不确定且为Wrap，优先用已确定高度的子节点填充，否则取maxSize。
    [self adjustHeightForWrappedElement:baseMsg
                        hasMatchedChild:visibleHeightMatchedElements.count > 0
                       hasMeasuredChild:hasMeasuredChild
                      isPaddingConsumed:NO
               maxHeightConsumedByChild:maxHeightConsumedByChild
                     maxAvailableHeight:maxSize.height];
    
    //第三次遍历：计算高match的可见子元素的大小
    for (TQDFMElementBase * element in visibleHeightMatchedElements) {
        CGFloat maxWidthForChild = contentWidthRemained;
        CGFloat maxHeightForChild = baseMsg.layoutFrame.size.height - baseMsg.paddingTop - baseMsg.paddingBottom;
        measureChildBlock(element,maxWidthForChild,maxHeightForChild, @"measure height matched child");
    }
    
    //计算自身整体宽度
    [self adjustWidthForWrappedElement:baseMsg
                       hasMatchedChild:visibleWidthMatchedElements.count > 0
                      hasMeasuredChild:hasMeasuredChild
                     isPaddingConsumed:NO
               maxWidthConsumedByChild:maxWidthConsumedByChild
                     maxAvailableWidth:maxSize.width];
    
    //第四次遍历：计算宽match的可见子元素的大小
    for (TQDFMElementBase * element in visibleWidthMatchedElements) {
        CGFloat maxHeightForChild = contentHeightRemained;
        CGFloat maxWidthForChild = baseMsg.layoutFrame.size.width - baseMsg.paddingLeft - baseMsg.paddingRight;
        measureChildBlock(element,maxHeightForChild,maxWidthForChild, @"measure width matched child");
    }
    
    //STEP2:排版子元素
    
    [self adjustFrameXForChildren:visibleElements inElement:baseMsg withMaxWidthConsumed:maxWidthConsumedByChild];
    [self adjustFrameYForChildren:visibleElements inElement:baseMsg withMaxHeightConsumed:maxHeightConsumedByChild];
    
    return baseMsg.layoutFrame.size;
}

@end
