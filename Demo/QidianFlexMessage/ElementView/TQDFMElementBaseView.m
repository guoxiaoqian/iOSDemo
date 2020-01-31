//
//  TQDFMElementBaseView.m
//  QQMSFContact
//
//  Created by gavinxqguo on 18/11/20.
//
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "TQDFMElementBaseView.h"
#import "TQDFMEvent.h"
#import "TQDFMElementLinearView.h"
#import "TQDFMElementContainerView.h"
#import "TQDFMElementFoldView.h"
#import "TQDFMElementTextView.h"
#import "TQDFMElementImageView.h"
#import "TQDFMElementButtonView.h"
#import "TQDFMElementDividerView.h"
#import "TQDFMElementBase.h"
#import "TQDFMElementText.h"
#import "TQDFMElementButton.h"
#import "TQDFMElementImage.h"
#import "TQDFMElementLoadingHolderView.h"
#import "TQDFMElementMsgView.h"

@interface TQDFMElementBaseView ()

@property (strong,nonatomic) TQDFMElementBase *baseMsg;
@property (strong,nonatomic) NSMutableArray* elementViews;
@property (strong,nonatomic) TQDFMEvent* actionEvent;
@property (assign,nonatomic) BOOL isHandleTouch;

@end

@implementation TQDFMElementBaseView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

#pragma mark - Common Layout & Render

+ (TQDFMElementBaseView *)createQDFMElementView:(TQDFMElementBase *)baseMsg withFrame:(CGRect)frame {
    TQDFMElementBaseView *baseView = nil;
    if ([baseMsg isKindOfClass:[TQDFMElementLinear class]]) {
        baseView = [[TQDFMElementLinearView alloc] initWithFrame:frame];
    } else if ([baseMsg isKindOfClass:[TQDFMElementContainer class]]) {
        baseView = [[TQDFMElementContainerView alloc] initWithFrame:frame];
    } else if ([baseMsg isKindOfClass:[TQDFMElementFold class]]) {
        baseView = [[TQDFMElementFoldView alloc] initWithFrame:frame];
    } else if ([baseMsg isKindOfClass:[TQDFMElementButton class]]) {
        baseView = [[TQDFMElementButtonView alloc] initWithFrame:frame];
    } else if ([baseMsg isKindOfClass:[TQDFMElementText class]]) {
        baseView = [[TQDFMElementTextView alloc] initWithFrame:frame];
    } else if ([baseMsg isKindOfClass:[TQDFMElementImage class]]) {
        baseView = [[TQDFMElementImageView alloc] initWithFrame:frame];
    } else if ([baseMsg isKindOfClass:[TQDFMElementDivider class]]) {
        baseView = [[TQDFMElementDividerView alloc] initWithFrame:frame];
    } else if ([baseMsg isKindOfClass:[TQDFMElementLoadingHolder class]]) {
        baseView = [[TQDFMElementLoadingHolderView alloc] initWithFrame:frame];
    }  else if ([baseMsg isKindOfClass:[TQDFMElementMsg class]]) {
        baseView = [[TQDFMElementMsgView alloc] initWithFrame:frame];
    } else {
        TQDFM_INFOP_ELEMENT(baseMsg,@"Unknow Element Type");
        baseView = [[TQDFMElementBaseView alloc] initWithFrame:frame];
        baseView.backgroundColor = [UIColor clearColor];
        baseView.userInteractionEnabled = NO;
    }
    
    return baseView;
}

//======================================================================
// 通用布局原则：
// . maxSize是父容器去掉padding和元素自身margin后剩余的空间，即元素自身布局时不用考虑父容器的padding和自身margin；
// . maxSize非法则不必布局；maxSize过小,则调整成与子元素一致的大小，使子元素正常布局
// . 最终返回的size不能超过maxSize；
// . 即允许子元素展示内容被父容器裁剪，但不允许破坏子元素已确定的宽高。
// . 支持布局结果备份和复用
//
// 特殊布局原则：
// . 特殊布局单纯关心Wrap情况下的大小计算，不用在乎布局大小超过了最大限制，也不用在乎自身aspectRatio，也不用备份自身布局结果。
// . 布局过程一般为：计算子元素大小，调整自身大小，排版子元素，返回自身大小
// . padding是所有容器都支持的，至少Linear和Frame
// . margin只有部分容器才支持(Linear和Frame)
//======================================================================

+ (CGSize)layoutQDFMElement:(TQDFMElementBase *)baseMsg withMaxSize:(CGSize)maxSize {
    
    // 布局空间非法， 则直接返回
    if (TQDFM_FLOAT_LESS_EQUAL_ZERO(maxSize.width) || TQDFM_FLOAT_LESS_EQUAL_ZERO(maxSize.height)) {
        [baseMsg setLayoutFrameForSure:CGRectZero];
        [baseMsg setLayoutFrameBackup:CGRectZero];
        return CGSizeZero;
    }
    
    // 布局优化：复用上次布局结果
#if TQDFM_REUSE_LAYOUT
    if (baseMsg.layoutContext && baseMsg.layoutContext.isDirty == NO) {
        [baseMsg setLayoutFrameForSure:baseMsg.layoutFrameBackup];
        return [baseMsg getLayoutSizeWithMaxSize:maxSize];
    }
#endif
    
    // 隐藏节点，则直接返回
    if (baseMsg.isHidden) {
        [baseMsg setLayoutFrameForSure:CGRectZero];
        [baseMsg setLayoutFrameBackup:CGRectZero];
        return CGSizeZero;
    }
    
    // 重置布局结果
    [baseMsg resetLayoutFrame];
    
    // 标记已确定的宽或高
    if (baseMsg.widthMode == TQDFM_MEASURE_EXACTLY) {
        [baseMsg setLayoutFrameWidth:baseMsg.width];
    } else if (baseMsg.widthMode == TQDFM_MEASURE_MATCH_PARRENT) {
        [baseMsg setLayoutFrameWidth:maxSize.width];
    }
    
    if (baseMsg.heightMode == TQDFM_MEASURE_EXACTLY) {
        [baseMsg setLayoutFrameHeight:baseMsg.height];
    } else if (baseMsg.heightMode == TQDFM_MEASURE_MATCH_PARRENT) {
        [baseMsg setLayoutFrameHeight:maxSize.height];
    }
    
    // 根据宽高比，进一步明确宽或高
    [baseMsg adjustSizeByAspectRatio];
    
    // 特殊布局，最多重试一次
    int layoutSpecailRetryCount = 0;
    while (layoutSpecailRetryCount <= 1) {
        
        // 已确定的宽或高，调整布局空间
        CGSize adjustedMaxSize = maxSize;
        if (baseMsg.isWidthSure) {
            adjustedMaxSize.width = ceilf(baseMsg.layoutFrame.size.width);
        }
        if (baseMsg.isHeightSure) {
            adjustedMaxSize.height = ceilf(baseMsg.layoutFrame.size.height);
        }
        
        // 调用特殊类型的布局接口
        if ([baseMsg isKindOfClass:[TQDFMElementLinear class]]){
            [TQDFMElementLinearView layoutSpecialQDFMElement:(TQDFMElementLinear*)baseMsg withMaxSize:adjustedMaxSize];
        } else if ([baseMsg isKindOfClass:[TQDFMElementContainer class]]){
            [TQDFMElementContainerView layoutSpecialQDFMElement:(TQDFMElementContainer*)baseMsg withMaxSize:adjustedMaxSize];
        } else if ([baseMsg isKindOfClass:[TQDFMElementFold class]]){
            [TQDFMElementFoldView layoutSpecialQDFMElement:(TQDFMElementFold*)baseMsg withMaxSize:adjustedMaxSize];
        } else if ([baseMsg isKindOfClass:[TQDFMElementButton class]]) { // Button可能继承Text，放在前面
            [TQDFMElementButtonView layoutSpecialQDFMElement:(TQDFMElementButton*)baseMsg withMaxSize:adjustedMaxSize];
        } else if ([baseMsg isKindOfClass:[TQDFMElementText class]]){
            [TQDFMElementTextView layoutSpecialQDFMElement:(TQDFMElementText*)baseMsg withMaxSize:adjustedMaxSize];
        } else if ([baseMsg isKindOfClass:[TQDFMElementImage class]]) {
            [TQDFMElementImageView layoutSpecialQDFMElement:(TQDFMElementImage*)baseMsg withMaxSize:adjustedMaxSize];
        } else if ([baseMsg isKindOfClass:[TQDFMElementLoadingHolder class]]) {
            [TQDFMElementLoadingHolderView layoutSpecialQDFMElement:(TQDFMElementLoadingHolder*)baseMsg withMaxSize:adjustedMaxSize];
        } else if ([baseMsg isKindOfClass:[TQDFMElementMsg class]]) {
            [TQDFMElementMsgView layoutSpecialQDFMElement:(TQDFMElementMsg*)baseMsg withMaxSize:adjustedMaxSize];
        }
        
        // 再检查一遍宽高比, 若有调整则重试一遍子元素布局
        if ([baseMsg adjustSizeByAspectRatio] == NO) {
            break;
        }
        layoutSpecailRetryCount ++;
    }
    
    
    if (baseMsg.isWidthSure == NO || baseMsg.isHeightSure == NO) {
        TQDFM_INFOP_ELEMENT(baseMsg, ([NSString stringWithFormat:@"layout failed, width:%d height:%d",baseMsg.isWidthSure,baseMsg.isHeightSure]));
        baseMsg.isWidthSure = YES;
        baseMsg.isHeightSure = YES;
    }
    
    // 备份布局结果，后面可复用
    [baseMsg setLayoutFrameBackup:baseMsg.layoutFrame];
    return [baseMsg getLayoutSizeWithMaxSize:maxSize];
}

- (void)renderQDFMElement:(TQDFMElementBase *)baseMsg {
    if (_baseMsg != baseMsg) {
        _baseMsg = baseMsg;
    }
    
    // STEP1: 渲染自身通用属性
    if (baseMsg.isHidden) {
        return;
    }
    
    if (baseMsg.background) {
        self.backgroundColor = [TQDFMElementBase getColorWithStr:baseMsg.background] ?: [UIColor clearColor];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
    
    if (baseMsg.alpha) {
        if ([baseMsg.alpha isEqualToString:@"0"]) {
            self.alpha = 0;
        } else if (baseMsg.alpha.floatValue > 0 && baseMsg.alpha.floatValue <= 1) {
            self.alpha = baseMsg.alpha.floatValue;
        }
    } else {
        self.alpha = 1;
    }
    
    if (baseMsg.cornerRadius && baseMsg.cornerRadius.floatValue > 0) {
        self.layer.cornerRadius = TQDFM_WIDTH_FROM_PIXEL(baseMsg.cornerRadius.floatValue);
        self.layer.masksToBounds = YES;
    } else {
        self.layer.cornerRadius = 0;
        self.layer.masksToBounds = NO;
    }
    
    if (baseMsg.borderWidth && baseMsg.cornerRadius.floatValue > 0) {
        self.layer.borderWidth = TQDFM_WIDTH_FROM_PIXEL(baseMsg.borderWidth.floatValue);
    } else {
        self.layer.borderWidth = 0;
    }
    
    if (baseMsg.borderColor) {
        self.layer.borderColor = [TQDFMElementBase getColorWithStr:baseMsg.borderColor].CGColor;
    } else {
        self.layer.borderColor = nil;
    }
    
    // STEP2: 渲染自身特殊属性
    [self renderSpecialQDFMElement:baseMsg];
    
    // STEP3: 渲染子元素
    // 先清理子元素视图
    for (UIView* subView in _elementViews) {
        [subView removeFromSuperview];
    }
    [_elementViews removeAllObjects];
    
    for (TQDFMElementBase* element in _baseMsg.subElements) {
        
        if ([element isKindOfClass:[TQDFMElementBase class]] == NO) {
            continue;
        }
        
        // 直接跳过隐藏的或大小为0的子元素
        if (CGRectIsEmpty(element.layoutFrame)) {
            continue;
        }
        
        // 优先复用子元素视图
        TQDFMElementBaseView *elementView = nil;
#if TQDFM_REUSE_VIEW
        if ([element shouldReuse] && [element.layoutContext.cell respondsToSelector:@selector(dequeueReusableElementViewWithIdentifier:)]) {
            elementView = (TQDFMElementBaseView *)[element.layoutContext.cell dequeueReusableElementViewWithIdentifier:element.reuseIdentifier];
        }
#endif
        if (!elementView) {
            elementView = [TQDFMElementBaseView createQDFMElementView:element withFrame:element.layoutFrame];
        }
        
        // 渲染子元素
        elementView.frame = element.layoutFrame;
        [elementView renderQDFMElement:element];
        
        // 事件响应支持
        elementView.actionDelegate = self.actionDelegate;
        
        // 添加子元素视图
        if (elementView != nil) {
            [self addSubview:elementView];
            [_elementViews addObject:elementView];
        } else {
            TQDFM_INFOP_ASSERT_ELEMENT(element, @"create element view failed");
        }
    }
    
    // STEP4: 设置事件
    if (baseMsg.action.length > 0) {
       _actionEvent = [[TQDFMEvent alloc] init];
        _actionEvent.action = baseMsg.action;
        _actionEvent.actionData = baseMsg.actionData;
    }
}

#pragma mark - Special Layout & Render

+ (CGSize)layoutSpecialQDFMElement:(TQDFMElementBase *)baseMsg withMaxSize:(CGSize)maxSize {
    return CGSizeZero;
}

- (void)renderSpecialQDFMElement:(TQDFMElementBase *)baseMsg {
    return;
}

#pragma mark - Reuse

- (BOOL)shouldReuse {
    return ((TQDFMElementBase*)self.baseMsg).shouldReuse;
}

- (void)prepareForReuse {
    _actionEvent = nil;
    self.hidden = NO;
}

- (NSString *)reuseIdentifier {
    return ((TQDFMElementBase*)self.baseMsg).reuseIdentifier;
}

#pragma mark - Event

- (BOOL)isElementEnable {
    return [((TQDFMElementBase*)_baseMsg).enable isEqualToString:@"false"] == NO;
}

- (BOOL)shouldRespondToTouch:(CGPoint)point {
    return [self isElementEnable];
}

- (BOOL)shouldDeliverEventToNextResponder {
    // Disable时，禁止事件冒泡 TODO-GAVIN
    return [self isElementEnable];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint  point = [touch locationInView:self];
    
    // 先检查区域是否允许接收点击
    if ([self shouldRespondToTouch:point]) {
        [self setHighlighted:YES];
        [self performSelector:@selector(setHighlighted:) withObject:nil afterDelay:0.3];

    } else {
        
        if ([self shouldDeliverEventToNextResponder]) {
            [super touchesBegan:touches withEvent:event];
        }
        
        return;
    }
    
    _isHandleTouch = YES;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_isHandleTouch == NO) {
        // 抛给上一层处理
        [self setHighlighted:NO];
        
        [super touchesEnded:touches withEvent:event];
        return;
    }
    
    UITouch* touch = [touches anyObject];
    CGPoint  point = [touch locationInView:self];
    _isHandleTouch = NO;
    
    [self didAction:point];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isHandleTouch == NO) {
        [super touchesCancelled:touches withEvent:event];
        return;
    }
    
    _isHandleTouch = NO;
}

- (void)setHighlighted:(BOOL)highlighted {
    _highlighted = highlighted;
    //TODO-GAVIN: 点击高亮
}

- (BOOL)didAction:(CGPoint)point{
    
    if (_actionEvent != nil) {
        // 自己有事件，直接抛给事件处理者
        [self.actionDelegate TQDFMElementView:self didAction:_actionEvent];
        return YES;
    } else {
        // 自己没事件，尝试抛给父视图处理
        if ([self.superview isKindOfClass:[TQDFMElementBaseView class]]) {
            [((TQDFMElementBaseView*)self.superview) didAction:point];
        }
        return NO;
    }
}

#pragma mark - 为了减包抽离的函数

+ (void)adjustFrameXForChildren:(NSArray*)visibleElements inElement:(TQDFMElementBase*)baseMsg withMaxWidthConsumed:(CGFloat)maxWidthConsumedByChild {
    switch (baseMsg.gravityHorizontal) {
        case TQDFM_GRAVITY_LEFT:{
            CGFloat childStartX = baseMsg.paddingLeft;
            for (TQDFMElementBase * element in visibleElements) {
                [element setLayoutFrameX:childStartX + element.marginLeft];
            }
        }
            break;
        case TQDFM_GRAVITY_RIGHT:{
            CGFloat childStartX = baseMsg.layoutFrame.size.width - baseMsg.paddingRight;
            for (TQDFMElementBase * element in visibleElements) {
                [element setLayoutFrameX:childStartX - element.marginRight - element.layoutFrame.size.width];
            }
        }
            break;
        case TQDFM_GRAVITY_CENTER_HORIZONTAL:{
            CGFloat childStartX = baseMsg.paddingLeft + (baseMsg.layoutFrame.size.width - baseMsg.paddingLeft - baseMsg.paddingRight - maxWidthConsumedByChild) / 2;
            for (TQDFMElementBase * element in visibleElements) {
                [element setLayoutFrameX:childStartX + (maxWidthConsumedByChild - element.layoutFrame.size.width) / 2 + element.marginLeft - element.marginRight];
            }
        }
            break;
        default:
            break;
    }
}

+ (void)adjustFrameYForChildren:(NSArray*)visibleElements inElement:(TQDFMElementBase*)baseMsg withMaxHeightConsumed:(CGFloat)maxHeightConsumedByChild {
    switch (baseMsg.gravityVertical) {
        case TQDFM_GRAVITY_TOP:{
            CGFloat childStartY = baseMsg.paddingTop;
            for (TQDFMElementBase * element in visibleElements) {
                [element setLayoutFrameY:childStartY + element.marginTop];
            }
        }
            break;
        case TQDFM_GRAVITY_BOTTOM:{
            CGFloat childStartY = baseMsg.layoutFrame.size.height - baseMsg.paddingBottom;
            for (TQDFMElementBase * element in visibleElements) {
                [element setLayoutFrameY:childStartY - element.marginBottom - element.layoutFrame.size.height];
            }
        }
            break;
        case TQDFM_GRAVITY_CENTER_VERTICAL:{
            CGFloat childStartY = baseMsg.paddingTop + (baseMsg.layoutFrame.size.height - baseMsg.paddingTop - baseMsg.paddingBottom - maxHeightConsumedByChild) / 2;
            for (TQDFMElementBase * element in visibleElements) {
                [element setLayoutFrameY:childStartY + (maxHeightConsumedByChild - element.layoutFrame.size.height) / 2 + element.marginTop - element.marginBottom];
            }
        }
            break;
        default:
            break;
    }
}

+ (CGSize)measureSizeForChild:(TQDFMElementBase *)element
             maxWidthForChild:(CGFloat)maxWidthForChild
            maxHeightForChild:(CGFloat)maxHeightForChild
     horizontalMarginConsumed:(BOOL)horizontalMarginConsumed
       verticalMarginConsumed:(BOOL)verticalMarginConsumed
      maxWidthConsumedByChild:(CGFloat*)maxWidthConsumedByChild
     maxHeightConsumedByChild:(CGFloat*)maxHeightConsumedByChild {
    
    BOOL needCosumeContentWidth = YES;
    if (element.isWidthSure == YES) {
        maxWidthForChild = element.layoutFrame.size.width;
        // 之前已经消耗过父容器的空间了
        needCosumeContentWidth = NO;
    } else if(element.widthMode == TQDFM_MEASURE_WRAP_CONTENT && horizontalMarginConsumed == NO) {
        if (element.gravityHorizontal == TQDFM_GRAVITY_CENTER_HORIZONTAL) {
            maxWidthForChild -= (element.marginLeft - element.marginRight);
        } else {
            maxWidthForChild -= (element.marginLeft + element.marginRight);
        }
    }
    
    BOOL needCosumeContentHeight = YES;
    if (element.isHeightSure == YES) {
        maxHeightForChild = element.layoutFrame.size.height;
        needCosumeContentHeight = NO;
    } else if(element.heightMode == TQDFM_MEASURE_WRAP_CONTENT && verticalMarginConsumed == NO) {
        if (element.gravityVertical == TQDFM_GRAVITY_CENTER_VERTICAL) {
            maxHeightForChild -= (element.marginTop - element.marginBottom);
        } else {
            maxHeightForChild -= (element.marginTop + element.marginBottom);
        }
    }
    
    CGSize childSize = [TQDFMElementBaseView layoutQDFMElement:element withMaxSize:CGSizeMake(maxWidthForChild, maxHeightForChild)];
    
    if (needCosumeContentWidth && maxWidthConsumedByChild != NULL) {
        if ( horizontalMarginConsumed == YES) { //Linear横向布局
            *maxWidthConsumedByChild += childSize.width;
        } else {
            if (element.gravityHorizontal == TQDFM_GRAVITY_CENTER_HORIZONTAL) {
                *maxWidthConsumedByChild = MAX(*maxWidthConsumedByChild, childSize.width + (element.marginLeft - element.marginRight));
            } else {
                *maxWidthConsumedByChild = MAX(*maxWidthConsumedByChild, childSize.width + (element.marginLeft + element.marginRight));
            }
        }
    }
    
    if (needCosumeContentHeight && maxHeightConsumedByChild != NULL) {
        if (verticalMarginConsumed == YES) { //Linear纵向布局
            *maxHeightConsumedByChild += childSize.height;
        } else {
            if (element.gravityVertical == TQDFM_GRAVITY_CENTER_VERTICAL) {
                *maxHeightConsumedByChild = MAX(*maxHeightConsumedByChild, childSize.height + (element.marginTop - element.marginBottom));
            } else {
                *maxHeightConsumedByChild = MAX(*maxHeightConsumedByChild, childSize.height + (element.marginTop + element.marginBottom));
            }
        }
    }
    
    return childSize;
}


+ (CGSize)measureSizeForChild:(TQDFMElementBase *)element
            maxHeightForChild:(CGFloat)maxHeightForChild
             maxWidthForChild:(CGFloat)maxWidthForChild
       verticalMarginConsumed:(BOOL)verticalMarginConsumed
     horizontalMarginConsumed:(BOOL)horizontalMarginConsumed
     maxHeightConsumedByChild:(CGFloat*)maxHeightConsumedByChild
      maxWidthConsumedByChild:(CGFloat*)maxWidthConsumedByChild {
    
    return [self measureSizeForChild:element
                    maxWidthForChild:maxWidthForChild
                   maxHeightForChild:maxHeightForChild
            horizontalMarginConsumed:horizontalMarginConsumed
              verticalMarginConsumed:verticalMarginConsumed
             maxWidthConsumedByChild:maxWidthConsumedByChild
            maxHeightConsumedByChild:maxHeightConsumedByChild];
}

+ (void)adjustHeightForWrappedElement:(TQDFMElementBase*)baseMsg
                      hasMatchedChild:(BOOL)hasMatchedChild
                     hasMeasuredChild:(BOOL)hasMeasuredChild
                    isPaddingConsumed:(BOOL)isPaddingConsumed
             maxHeightConsumedByChild:(CGFloat)maxHeightConsumedByChild
                   maxAvailableHeight:(CGFloat)maxAvailableHeight {
    
    if (baseMsg.isHeightSure == NO && baseMsg.heightMode == TQDFM_MEASURE_WRAP_CONTENT) {
        
        CGFloat extraPadding = isPaddingConsumed? 0 : baseMsg.paddingTop + baseMsg.paddingBottom;
        
        if (hasMatchedChild == NO) {
            [baseMsg setLayoutFrameHeight:maxHeightConsumedByChild + extraPadding];
        } else {
            if(hasMeasuredChild){
                [baseMsg setLayoutFrameHeight:maxHeightConsumedByChild + extraPadding];
            } else {
                //父Wrap,子Match，应该把子压成0，跟Android表现一致
//                [baseMsg setLayoutFrameHeight:maxAvailableHeight];
                [baseMsg setLayoutFrameHeight:extraPadding];
            }
        }
    }
}

+ (void)adjustWidthForWrappedElement:(TQDFMElementBase*)baseMsg
                     hasMatchedChild:(BOOL)hasMatchedChild
                    hasMeasuredChild:(BOOL)hasMeasuredChild
                   isPaddingConsumed:(BOOL)isPaddingConsumed
             maxWidthConsumedByChild:(CGFloat)maxWidthConsumedByChild
                   maxAvailableWidth:(CGFloat)maxAvailableWidth {
    
    if (baseMsg.isWidthSure == NO && baseMsg.widthMode == TQDFM_MEASURE_WRAP_CONTENT) {
        
        CGFloat extraPadding = isPaddingConsumed? 0 : baseMsg.paddingLeft + baseMsg.paddingRight;
        
        if (hasMatchedChild == NO) {
            [baseMsg setLayoutFrameWidth:maxWidthConsumedByChild + extraPadding];
        } else {
            if(hasMeasuredChild){
                [baseMsg setLayoutFrameWidth:maxWidthConsumedByChild + extraPadding];
            } else {
                //父Wrap,子Match，应该把子压成0，跟Android表现一致
//                [baseMsg setLayoutFrameWidth:maxAvailableWidth];
                [baseMsg setLayoutFrameWidth:extraPadding];
            }
        }
    }
}

+ (void)classifyChildernForElement:(TQDFMElementBase*)baseMsg
                   visibleElements:(NSMutableArray*)visibleElements
           visibleWeightedElements:(NSMutableArray*)visibleWeightedElements
       visibleWidthMatchedElements:(NSMutableArray*)visibleWidthMatchedElements
      visibleHeightMatchedElements:(NSMutableArray*)visibleHeightMatchedElements
         visibleMeasurableElements:(NSMutableArray*)visibleMeasurableElements
                    childWeightSum:(CGFloat*)childWeightSum
              contentWidthConsumed:(CGFloat*)contentWidthConsumed
              contentWidthRemained:(CGFloat)contentWidthRemained
          maxHeightConsumedByChild:(CGFloat*)maxHeightConsumedByChild
             contentHeightConsumed:(CGFloat*)contentHeightConsumed
             contentHeightRemained:(CGFloat)contentHeightRemained
           maxWidthConsumedByChild:(CGFloat*)maxWidthConsumedByChild {
    
    BOOL isLinearHorizontal = contentWidthConsumed && maxHeightConsumedByChild;
    BOOL isLinearVertical = contentHeightConsumed && maxWidthConsumedByChild;
    
    for (TQDFMElementBase * element in baseMsg.subElements) {
        
        //清理子元素布局
        [element resetLayoutFrame];
        
        if (element.isHidden) {
            continue;
        }
        [visibleElements addObject:element];
        
        // Linear布局时，用子元素的margin去消耗父容器空间
        if (isLinearHorizontal) {
            *contentWidthConsumed += element.marginLeft + element.marginRight;
        } else if (isLinearVertical) {
            *contentHeightConsumed += element.marginTop + element.marginBottom;
        }
        
        switch (element.widthMode) {
            case TQDFM_MEASURE_EXACTLY: {
                [element setLayoutFrameWidth:element.width];
            }
                break;
            case TQDFM_MEASURE_MATCH_PARRENT: {
                if (isLinearHorizontal) {
                    if (element.weight > 0) {
                        *childWeightSum += element.weight;
                        [visibleWeightedElements addObject:element];
                    } else {
                        [visibleWidthMatchedElements addObject:element];
                    }
                } else {
                    if (baseMsg.isWidthSure == NO) {
                        [visibleWidthMatchedElements addObject:element];
                    } else {
                        if (baseMsg.gravityHorizontal == TQDFM_GRAVITY_CENTER_HORIZONTAL) {
                            [element setLayoutFrameWidth:contentWidthRemained - (element.marginLeft - element.marginRight)];
                        } else {
                            [element setLayoutFrameWidth:contentWidthRemained - (element.marginLeft + element.marginRight)];
                        }
                    }
                }
            }
                break;
            default:
                break;
        }
        
        switch (element.heightMode) {
            case TQDFM_MEASURE_EXACTLY: {
                [element setLayoutFrameHeight:element.height];
            }
                break;
            case TQDFM_MEASURE_MATCH_PARRENT: {
                if (isLinearVertical) {
                    if (element.weight > 0) {
                        *childWeightSum += element.weight;
                        [visibleWeightedElements addObject:element];
                    } else {
                        [visibleHeightMatchedElements addObject:element];
                    }
                } else {
                    if (baseMsg.isHeightSure == NO) {
                        [visibleHeightMatchedElements addObject:element];
                    } else {
                        if (baseMsg.gravityVertical == TQDFM_GRAVITY_CENTER_VERTICAL) {
                            [element setLayoutFrameHeight:contentHeightRemained - (element.marginTop - element.marginBottom)];
                        } else {
                            [element setLayoutFrameHeight:contentHeightRemained - (element.marginTop + element.marginBottom)];
                        }
                    }
                }
            }
                break;
            default:
                break;
        }
        
        // 根据宽高比调整一下大小
        [element adjustSizeByAspectRatio];
        
        // 已确定的子元素宽高去消耗父容器空间
        if (element.isWidthSure) {
            if (isLinearHorizontal) {
                *contentWidthConsumed += element.layoutFrame.size.width;
            } else {
                if (element.gravityHorizontal == TQDFM_GRAVITY_CENTER_HORIZONTAL) {
                    *maxWidthConsumedByChild = MAX(*maxWidthConsumedByChild, element.layoutFrame.size.width + (element.marginLeft - element.marginRight));
                } else {
                    *maxWidthConsumedByChild = MAX(*maxWidthConsumedByChild, element.layoutFrame.size.width + (element.marginLeft + element.marginRight));
                }
            }
        }
        if (element.isHeightSure) {
            if (isLinearVertical) {
                *contentHeightConsumed += element.layoutFrame.size.height;
            } else {
                if (element.gravityVertical == TQDFM_GRAVITY_CENTER_VERTICAL) {
                    *maxHeightConsumedByChild = MAX(*maxHeightConsumedByChild, element.layoutFrame.size.height + (element.marginTop - element.marginBottom));
                } else {
                    *maxHeightConsumedByChild = MAX(*maxHeightConsumedByChild, element.layoutFrame.size.height + (element.marginTop + element.marginBottom));
                }
            }
        }
    }
    
    //确定可以直接计算大小的子元素
    [visibleMeasurableElements addObjectsFromArray:visibleElements];
    [visibleMeasurableElements removeObjectsInArray:visibleWeightedElements];
    [visibleMeasurableElements removeObjectsInArray:visibleWidthMatchedElements];
    [visibleMeasurableElements removeObjectsInArray:visibleHeightMatchedElements];
}

+ (void)classifyChildernForElement:(TQDFMElementBase*)baseMsg
                   visibleElements:(NSMutableArray*)visibleElements
           visibleWeightedElements:(NSMutableArray*)visibleWeightedElements
      visibleHeightMatchedElements:(NSMutableArray*)visibleHeightMatchedElements
       visibleWidthMatchedElements:(NSMutableArray*)visibleWidthMatchedElements
         visibleMeasurableElements:(NSMutableArray*)visibleMeasurableElements
                    childWeightSum:(CGFloat*)childWeightSum
             contentHeightConsumed:(CGFloat*)contentHeightConsumed
             contentHeightRemained:(CGFloat)contentHeightRemained
           maxWidthConsumedByChild:(CGFloat*)maxWidthConsumedByChild
              contentWidthConsumed:(CGFloat*)contentWidthConsumed
              contentWidthRemained:(CGFloat)contentWidthRemained
          maxHeightConsumedByChild:(CGFloat*)maxHeightConsumedByChild {
    
    [self classifyChildernForElement:baseMsg
                     visibleElements:visibleElements
             visibleWeightedElements:visibleWeightedElements
         visibleWidthMatchedElements:visibleWidthMatchedElements
        visibleHeightMatchedElements:visibleHeightMatchedElements
           visibleMeasurableElements:visibleMeasurableElements
                      childWeightSum:childWeightSum
                contentWidthConsumed:contentWidthConsumed
                contentWidthRemained:contentWidthRemained
            maxHeightConsumedByChild:maxHeightConsumedByChild
               contentHeightConsumed:contentHeightConsumed
               contentHeightRemained:contentHeightRemained
             maxWidthConsumedByChild:maxWidthConsumedByChild];
}


@end
