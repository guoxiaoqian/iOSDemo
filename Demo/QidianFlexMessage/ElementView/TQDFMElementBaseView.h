//
//  TQDFMElementBaseView.h
//  QQMSFContact
//
//  Created by gavinxqguo on 18/11/20.
//
//

@class TQDFMElementBase;
@class TQDFMElementBaseView;
@class TQDFMEvent;

@interface TQDFMElementBaseView : UIView

@property (nonatomic, assign) BOOL highlighted;
@property (strong,nonatomic) TQDFMElementBase *baseMsg;
@property (strong,nonatomic) NSMutableArray* elementViews;

#pragma mark - Common Layout & Render

// 工厂方法，根据Element类型创建不同视图
+ (TQDFMElementBaseView *)createQDFMElementView:(TQDFMElementBase *)baseMsg withFrame:(CGRect)frame;

// 根据结点测量自身大小，并测量和布局子元素，返回自身大小
+ (CGSize)layoutQDFMElement:(TQDFMElementBase *)baseMsg withMaxSize:(CGSize)maxSize;

// 根据节点渲染自身，并创建和渲染子视图
- (void)renderQDFMElement:(TQDFMElementBase *)baseMsg;

#pragma mark - Special Layout & Render

+ (CGSize)layoutSpecialQDFMElement:(TQDFMElementBase *)baseMsg withMaxSize:(CGSize)maxSize;

- (void)renderSpecialQDFMElement:(TQDFMElementBase *)baseMsg;

- (UIView*)contentViewToRenderChildren;

#pragma mark - Event

- (void)handleHighlited:(BOOL)highlited;

- (void)handleEvent:(TQDFMEvent*)event;

#pragma mark - Reuse

- (BOOL)shouldReuse;

- (void)prepareForReuse;

- (NSString *)reuseIdentifier;

#pragma mark - 为了减包抽离的函数，有点恶心，勿喷

+ (void)adjustFrameXForChildren:(NSArray*)visibleElements inElement:(TQDFMElementBase*)baseMsg withMaxWidthConsumed:(CGFloat)maxWidthConsumedByChild;
+ (void)adjustFrameYForChildren:(NSArray*)visibleElements inElement:(TQDFMElementBase*)baseMsg withMaxHeightConsumed:(CGFloat)maxHeightConsumedByChild;

+ (CGSize)measureSizeForChild:(TQDFMElementBase *)element
             maxWidthForChild:(CGFloat)maxWidthForChild
            maxHeightForChild:(CGFloat)maxHeightForChild
     horizontalMarginConsumed:(BOOL)horizontalMarginConsumed
       verticalMarginConsumed:(BOOL)verticalMarginConsumed
      maxWidthConsumedByChild:(CGFloat*)maxWidthConsumedByChild
     maxHeightConsumedByChild:(CGFloat*)maxHeightConsumedByChild;

+ (CGSize)measureSizeForChild:(TQDFMElementBase *)element
            maxHeightForChild:(CGFloat)maxHeightForChild
             maxWidthForChild:(CGFloat)maxWidthForChild
       verticalMarginConsumed:(BOOL)verticalMarginConsumed
     horizontalMarginConsumed:(BOOL)horizontalMarginConsumed
     maxHeightConsumedByChild:(CGFloat*)maxHeightConsumedByChild
      maxWidthConsumedByChild:(CGFloat*)maxWidthConsumedByChild;

+ (void)adjustHeightForWrappedElement:(TQDFMElementBase*)baseMsg
                      hasMatchedChild:(BOOL)hasMatchedChild
                     hasMeasuredChild:(BOOL)hasMeasuredChild
                    isPaddingConsumed:(BOOL)isPaddingConsumed
             maxHeightConsumedByChild:(CGFloat)maxHeightConsumedByChild
                   maxAvailableHeight:(CGFloat)maxAvailableHeight;

+ (void)adjustWidthForWrappedElement:(TQDFMElementBase*)baseMsg
                      hasMatchedChild:(BOOL)hasMatchedChild
                     hasMeasuredChild:(BOOL)hasMeasuredChild
                   isPaddingConsumed:(BOOL)isPaddingConsumed
             maxWidthConsumedByChild:(CGFloat)maxWidthConsumedByChild
                   maxAvailableWidth:(CGFloat)maxAvailableWidth;


+ (void)classifyChildernForElement:(TQDFMElementBase*)baseMsg
                   visibleElements:(NSMutableArray*)visibleElements
           visibleWeightedElements:(NSMutableArray*)visibleWeightedElements
       visibleWidthMatchedElements:(NSMutableArray*)visibleWidthMatchedElements
      visibleHeightMatchedElements:(NSMutableArray*)visibleHeightMatchedElements
         visibleMeasurableElements:(NSMutableArray*)visibleMeasurableElements
                    childWeightSum:(CGFloat*)childWeightSum
              contentWidthConsumed:(CGFloat*)contentWidthConsumed //Linear横向布局时，所有子元素总共消耗的宽度，会自动累加
              contentWidthRemained:(CGFloat)contentWidthRemained
          maxHeightConsumedByChild:(CGFloat*)maxHeightConsumedByChild //Linear横向布局或Container布局时，子元素消耗的最高度，会自动取最大值
             contentHeightConsumed:(CGFloat*)contentHeightConsumed //Linear纵向布局时，所有子元素总共消耗的高度，会自动累加
             contentHeightRemained:(CGFloat)contentHeightRemained
           maxWidthConsumedByChild:(CGFloat*)maxWidthConsumedByChild; //Linear纵向布局或Container布局时，子元素消耗的最大宽度，会自动取最大值

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
          maxHeightConsumedByChild:(CGFloat*)maxHeightConsumedByChild;


@end
