//
//  TQDFMElementLinearView.m
//  QQ
//
//  Created by 郭晓倩 on 2018/11/21.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


#import "TQDFMElementLinearView.h"
#import "TQDFMElementBase.h"

@implementation TQDFMElementLinearView

+ (CGSize)layoutSpecialQDFMElement:(TQDFMElementLinear *)baseMsg withMaxSize:(CGSize)maxSize {
    
    if ([baseMsg.orientation isEqualToString:@"vertical"]) {
        [self layoutVertical:baseMsg withMaxSize:maxSize];
    } else {
        [self layoutHorizontal:baseMsg withMaxSize:maxSize];
    }
    
    return baseMsg.layoutFrame.size;
}


//======================================================================
// Linear测量原则：
// 1. 只要一明确子元素的宽高，就去消耗父容器空间
// 2. 测量子元素时，优先使用子元素已确定的宽高，作为最大布局范围
//======================================================================

+ (CGSize)layoutHorizontal:(TQDFMElementLinear *)baseMsg withMaxSize:(CGSize)maxSize {
    
    // STEP1: 测量子元素和自身大小
    
    CGFloat childWeightSum = 0;
    __block CGFloat contentWidthConsumed = baseMsg.paddingLeft + baseMsg.paddingRight;
    __block CGFloat maxHeightConsumedByChild = 0;
    __block BOOL hasMeasuredChild = NO;
    CGFloat contentHeightRemained = maxSize.height - baseMsg.paddingTop - baseMsg.paddingBottom;
    NSMutableArray* visibleElements = [NSMutableArray new];
    NSMutableArray* visibleWeightedElements = [NSMutableArray new];
    NSMutableArray* visibleWidthMatchedElements = [NSMutableArray new];
    NSMutableArray* visibleHeightMatchedElements = [NSMutableArray new];
    NSMutableArray* visibleMeasurableElements = [NSMutableArray new];
    
    //第一次遍历：将元素分类，计算weight总和及已用宽度
    [self classifyChildernForElement:baseMsg
                     visibleElements:visibleElements
             visibleWeightedElements:visibleWeightedElements
         visibleWidthMatchedElements:visibleWidthMatchedElements
        visibleHeightMatchedElements:visibleHeightMatchedElements
           visibleMeasurableElements:visibleMeasurableElements
                      childWeightSum:&childWeightSum
                contentWidthConsumed:&contentWidthConsumed
                contentWidthRemained:0
            maxHeightConsumedByChild:&maxHeightConsumedByChild
               contentHeightConsumed:nil
               contentHeightRemained:contentHeightRemained
             maxWidthConsumedByChild:nil];
    
    //校验剩余宽度
    __block CGFloat contentWidthRemained = maxSize.width - contentWidthConsumed;
    if (TQDFM_FLOAT_LESS_THAN_ZERO(contentWidthRemained)) {
        TQDFM_INFOP_ASSERT_ELEMENT(baseMsg, @"linear width not enough");
    }
    contentWidthRemained = MAX(0, contentWidthRemained);
    if (TQDFM_FLOAT_LESS_THAN_ZERO(contentHeightRemained)) {
        TQDFM_INFOP_ASSERT_ELEMENT(baseMsg, @"linear height not enough");
    }
    contentHeightRemained = MAX(0, contentHeightRemained);
    
    
    //计算单个子元素大小的Block
    void (^measureChildBlock)(TQDFMElementBase *, CGFloat, CGFloat, NSString*) = ^(TQDFMElementBase * element,CGFloat maxWidthForChild, CGFloat maxHeightForChild,NSString* measureStep) {
        
        hasMeasuredChild = YES;
        
        //计算单个子元素大小和消耗空间
        CGFloat oldContentWidthConsumed = contentWidthConsumed;
        [self measureSizeForChild:element
                 maxWidthForChild:maxWidthForChild
                maxHeightForChild:maxHeightForChild
         horizontalMarginConsumed:YES
           verticalMarginConsumed:NO
          maxWidthConsumedByChild:&contentWidthConsumed
         maxHeightConsumedByChild:&maxHeightConsumedByChild];
        
        //重新计算剩余宽度
        if (contentWidthConsumed > oldContentWidthConsumed) {
            contentWidthRemained -= (contentWidthConsumed - oldContentWidthConsumed);
            if (TQDFM_FLOAT_LESS_THAN_ZERO(contentWidthRemained)) {
                TQDFM_INFOP_ASSERT_ELEMENT(element,([NSString stringWithFormat:@"linear width not enough when %@",measureStep]));
            }
            contentWidthRemained = MAX(0, contentWidthRemained);
        }
    };
    
    
    //第二次遍历：计算可测量的子元素（宽非weight/宽非match/高非match）的大小
    for (TQDFMElementBase * element in visibleMeasurableElements) {
        CGFloat maxWidthForChild = contentWidthRemained;
        CGFloat maxHeightForChild = contentHeightRemained;
        measureChildBlock(element,maxWidthForChild,maxHeightForChild, @"measure exact child");
    }
    
    //第三次遍历：计算宽weight的可见子元素的大小
    CGFloat widthUnitPerWeight = contentWidthRemained / childWeightSum;
    for (TQDFMElementBase * element in visibleWeightedElements) {
        CGFloat maxWidthForChild = element.weight * widthUnitPerWeight;
        if ([visibleHeightMatchedElements containsObject:element]) {
            [element setLayoutFrameWidth:maxWidthForChild];
            contentWidthConsumed += maxWidthForChild;
            contentWidthRemained -= maxWidthForChild;
        } else {
            CGFloat maxHeightForChild = contentHeightRemained;
            measureChildBlock(element,maxWidthForChild,maxHeightForChild, @"measure weighted child");
        }
    }
    
    //第四次遍历：计算宽match的可见子元素的大小: 如果子元素有多个，则平分剩余空间
    CGFloat widthUnitPerMatch = contentWidthRemained / visibleWidthMatchedElements.count;
    for (TQDFMElementBase * element in visibleWidthMatchedElements) {
        CGFloat maxWidthForChild = widthUnitPerMatch;
        if ([visibleHeightMatchedElements containsObject:element]) {
            [element setLayoutFrameWidth:maxWidthForChild];
            contentWidthConsumed += maxWidthForChild;
            contentWidthRemained -= maxWidthForChild;
        } else {
            CGFloat maxHeightForChild = contentHeightRemained;
            measureChildBlock(element,maxWidthForChild,maxHeightForChild, @"measure width matched child");
        }
    }
    
    //计算自身整体高度：高度不确定且为Wrap，优先用已确定高度的子节点填充，否则取maxSize。
    [self adjustHeightForWrappedElement:baseMsg
                        hasMatchedChild:visibleHeightMatchedElements.count > 0
                       hasMeasuredChild:hasMeasuredChild
                      isPaddingConsumed:NO
               maxHeightConsumedByChild:maxHeightConsumedByChild
                     maxAvailableHeight:maxSize.height];
    
    //第五次遍历：计算高match的可见子元素的大小
    for (TQDFMElementBase * element in visibleHeightMatchedElements) {
        CGFloat maxWidthForChild = contentWidthRemained;
        CGFloat maxHeightForChild = baseMsg.layoutFrame.size.height - baseMsg.paddingTop - baseMsg.paddingBottom;
        measureChildBlock(element,maxWidthForChild,maxHeightForChild, @"measure height matched child");
    }
    
    //计算自身整体宽度
    [self adjustWidthForWrappedElement:baseMsg
                       hasMatchedChild:visibleWeightedElements.count > 0 || visibleWidthMatchedElements.count > 0
                      hasMeasuredChild:hasMeasuredChild
                     isPaddingConsumed:YES
               maxWidthConsumedByChild:contentWidthConsumed
                     maxAvailableWidth:maxSize.width];
    
    // STEP2: 排版子元素
    
    //计算子元素的FrameX
    switch (baseMsg.gravityHorizontal) {
        case TQDFM_GRAVITY_LEFT:{
            CGFloat childStartX = baseMsg.paddingLeft;
            for (TQDFMElementBase * element in visibleElements) {
                [element setLayoutFrameX:childStartX + element.marginLeft];
                childStartX = CGRectGetMaxX(element.layoutFrame) + element.marginRight;
            }
        }
            break;
        case TQDFM_GRAVITY_RIGHT:{
            CGFloat childStartX = baseMsg.layoutFrame.size.width - baseMsg.paddingRight;
            for (int i = (int)visibleElements.count -1; i >= 0; i--) {
                TQDFMElementBase * element = visibleElements[i];
                [element setLayoutFrameX: childStartX - element.marginRight - element.layoutFrame.size.width];
                childStartX = CGRectGetMinX(element.layoutFrame) - element.marginLeft;
            }
        }
            break;
        case TQDFM_GRAVITY_CENTER_HORIZONTAL:{
            CGFloat childStartX = baseMsg.paddingLeft + (baseMsg.layoutFrame.size.width - contentWidthConsumed) / 2;
            for (TQDFMElementBase * element in visibleElements) {
                [element setLayoutFrameX:childStartX + element.marginLeft];
                childStartX = CGRectGetMaxX(element.layoutFrame) + element.marginRight;
            }
        }
            break;
        default:
            break;
    }
    
    //计算子元素的FrameY
    [self adjustFrameYForChildren:visibleElements inElement:baseMsg withMaxHeightConsumed:maxHeightConsumedByChild];
    
    return baseMsg.layoutFrame.size;
}



//======================================================================
// 以下脚本内容是脚本转换生成，请仅维护layoutHorizontal
//======================================================================


+ (CGSize)layoutVertical:(TQDFMElementLinear *)baseMsg withMaxSize:(CGSize)maxSize {
    
    // STEP1: 测量子元素和自身大小
    
    CGFloat childWeightSum = 0;
    __block CGFloat contentHeightConsumed = baseMsg.paddingTop + baseMsg.paddingBottom;
    __block CGFloat maxWidthConsumedByChild = 0;
    __block BOOL hasMeasuredChild = NO;
    CGFloat contentWidthRemained = maxSize.width - baseMsg.paddingLeft - baseMsg.paddingRight;
    NSMutableArray* visibleElements = [NSMutableArray new];
    NSMutableArray* visibleWeightedElements = [NSMutableArray new];
    NSMutableArray* visibleHeightMatchedElements = [NSMutableArray new];
    NSMutableArray* visibleWidthMatchedElements = [NSMutableArray new];
    NSMutableArray* visibleMeasurableElements = [NSMutableArray new];
    
    //第一次遍历：将元素分类，计算weight总和及已用高度
    [self classifyChildernForElement:baseMsg
                     visibleElements:visibleElements
             visibleWeightedElements:visibleWeightedElements
        visibleHeightMatchedElements:visibleHeightMatchedElements
         visibleWidthMatchedElements:visibleWidthMatchedElements
           visibleMeasurableElements:visibleMeasurableElements
                      childWeightSum:&childWeightSum
               contentHeightConsumed:&contentHeightConsumed
               contentHeightRemained:0
             maxWidthConsumedByChild:&maxWidthConsumedByChild
                contentWidthConsumed:nil
                contentWidthRemained:contentWidthRemained
            maxHeightConsumedByChild:nil];
    
    //校验剩余高度
    __block CGFloat contentHeightRemained = maxSize.height - contentHeightConsumed;
    if (TQDFM_FLOAT_LESS_THAN_ZERO(contentHeightRemained)) {
        TQDFM_INFOP_ASSERT_ELEMENT(baseMsg, @"linear height not enough");
    }
    contentHeightRemained = MAX(0, contentHeightRemained);
    if (TQDFM_FLOAT_LESS_THAN_ZERO(contentWidthRemained)) {
        TQDFM_INFOP_ASSERT_ELEMENT(baseMsg, @"linear width not enough");
    }
    contentWidthRemained = MAX(0, contentWidthRemained);
    
    
    //计算单个子元素大小的Block
    void (^measureChildBlock)(TQDFMElementBase *, CGFloat, CGFloat, NSString*) = ^(TQDFMElementBase * element,CGFloat maxHeightForChild, CGFloat maxWidthForChild,NSString* measureStep) {
        
        hasMeasuredChild = YES;
        
        //计算单个子元素大小和消耗空间
        CGFloat oldContentHeightConsumed = contentHeightConsumed;
        [self measureSizeForChild:element
                maxHeightForChild:maxHeightForChild
                 maxWidthForChild:maxWidthForChild
           verticalMarginConsumed:YES
         horizontalMarginConsumed:NO
         maxHeightConsumedByChild:&contentHeightConsumed
          maxWidthConsumedByChild:&maxWidthConsumedByChild];
        
        //重新计算剩余高度
        if (contentHeightConsumed > oldContentHeightConsumed) {
            contentHeightRemained -= (contentHeightConsumed - oldContentHeightConsumed);
            if (TQDFM_FLOAT_LESS_THAN_ZERO(contentHeightRemained)) {
                TQDFM_INFOP_ASSERT_ELEMENT(element,([NSString stringWithFormat:@"linear height not enough when %@",measureStep]));
            }
            contentHeightRemained = MAX(0, contentHeightRemained);
        }
    };
    
    
    //第二次遍历：计算可测量的子元素（高非weight/高非match/宽非match）的大小
    for (TQDFMElementBase * element in visibleMeasurableElements) {
        CGFloat maxHeightForChild = contentHeightRemained;
        CGFloat maxWidthForChild = contentWidthRemained;
        measureChildBlock(element,maxHeightForChild,maxWidthForChild, @"measure exact child");
    }
    
    //第三次遍历：计算高weight的可见子元素的大小
    CGFloat heightUnitPerWeight = contentHeightRemained / childWeightSum;
    for (TQDFMElementBase * element in visibleWeightedElements) {
        CGFloat maxHeightForChild = element.weight * heightUnitPerWeight;
        if ([visibleWidthMatchedElements containsObject:element]) {
            [element setLayoutFrameHeight:maxHeightForChild];
            contentHeightConsumed += maxHeightForChild;
            contentHeightRemained -= maxHeightForChild;
        } else {
            CGFloat maxWidthForChild = contentWidthRemained;
            measureChildBlock(element,maxHeightForChild,maxWidthForChild, @"measure weighted child");
        }
    }
    
    //第四次遍历：计算高match的可见子元素的大小: 如果子元素有多个，则平分剩余空间
    CGFloat heightUnitPerMatch = contentHeightRemained / visibleHeightMatchedElements.count;
    for (TQDFMElementBase * element in visibleHeightMatchedElements) {
        CGFloat maxHeightForChild = heightUnitPerMatch;
        if ([visibleWidthMatchedElements containsObject:element]) {
            [element setLayoutFrameHeight:maxHeightForChild];
            contentHeightConsumed += maxHeightForChild;
            contentHeightRemained -= maxHeightForChild;
        } else {
            CGFloat maxWidthForChild = contentWidthRemained;
            measureChildBlock(element,maxHeightForChild,maxWidthForChild, @"measure height matched child");
        }
    }
    
    //计算自身整体宽度：宽度不确定且为Wrap，优先用已确定宽度的子节点填充，否则取maxSize。
    [self adjustWidthForWrappedElement:baseMsg
                       hasMatchedChild:visibleWidthMatchedElements.count > 0
                      hasMeasuredChild:hasMeasuredChild
                     isPaddingConsumed:NO
               maxWidthConsumedByChild:maxWidthConsumedByChild
                     maxAvailableWidth:maxSize.width];
    
    //第五次遍历：计算宽match的可见子元素的大小
    for (TQDFMElementBase * element in visibleWidthMatchedElements) {
        CGFloat maxHeightForChild = contentHeightRemained;
        CGFloat maxWidthForChild = baseMsg.layoutFrame.size.width - baseMsg.paddingLeft - baseMsg.paddingRight;
        measureChildBlock(element,maxHeightForChild,maxWidthForChild, @"measure width matched child");
    }
    
    //计算自身整体高度
    [self adjustHeightForWrappedElement:baseMsg
                        hasMatchedChild:visibleWeightedElements.count > 0 || visibleHeightMatchedElements.count > 0
                       hasMeasuredChild:hasMeasuredChild
                      isPaddingConsumed:YES
               maxHeightConsumedByChild:contentHeightConsumed
                     maxAvailableHeight:maxSize.height];
    
    // STEP2: 排版子元素
    
    //计算子元素的FrameY
    switch (baseMsg.gravityVertical) {
        case TQDFM_GRAVITY_TOP:{
            CGFloat childStartY = baseMsg.paddingTop;
            for (TQDFMElementBase * element in visibleElements) {
                [element setLayoutFrameY:childStartY + element.marginTop];
                childStartY = CGRectGetMaxY(element.layoutFrame) + element.marginBottom;
            }
        }
            break;
        case TQDFM_GRAVITY_BOTTOM:{
            CGFloat childStartY = baseMsg.layoutFrame.size.height - baseMsg.paddingBottom;
            for (int i = (int)visibleElements.count -1; i >= 0; i--) {
                TQDFMElementBase * element = visibleElements[i];
                [element setLayoutFrameY: childStartY - element.marginBottom - element.layoutFrame.size.height];
                childStartY = CGRectGetMinY(element.layoutFrame) - element.marginTop;
            }
        }
            break;
        case TQDFM_GRAVITY_CENTER_VERTICAL:{
            CGFloat childStartY = baseMsg.paddingTop + (baseMsg.layoutFrame.size.height - contentHeightConsumed) / 2;
            for (TQDFMElementBase * element in visibleElements) {
                [element setLayoutFrameY:childStartY + element.marginTop];
                childStartY = CGRectGetMaxY(element.layoutFrame) + element.marginBottom;
            }
        }
            break;
        default:
            break;
    }
    
    //计算子元素的FrameX
    [self adjustFrameXForChildren:visibleElements inElement:baseMsg withMaxWidthConsumed:maxWidthConsumedByChild];
    
    return baseMsg.layoutFrame.size;
}

@end
