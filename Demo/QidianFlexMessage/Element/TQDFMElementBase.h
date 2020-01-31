//
//  TQDFMElementBase.h
//  QQMSFContact
//
//  Created by gavinxqguo on 18/11/20.
//
//

#import "TQDFMLayoutContext.h"
#import "TQDFMCommon.h"

typedef enum : NSUInteger {
    TQDFM_MEASURE_EXACTLY                = 1,
    TQDFM_MEASURE_MATCH_PARRENT          = -1,
    TQDFM_MEASURE_WRAP_CONTENT           = -2,
} TQDFMMeasureMode;

typedef enum : NSUInteger {
    TQDFM_GRAVITY_LEFT                   = 1,
    TQDFM_GRAVITY_RIGHT                  = 1 << 1,
    TQDFM_GRAVITY_CENTER_HORIZONTAL      = 1 << 2,
    TQDFM_GRAVITY_TOP                    = 1 << 3,
    TQDFM_GRAVITY_BOTTOM                 = 1 << 4,
    TQDFM_GRAVITY_CENTER_VERTICAL        = 1 << 5,
} TQDFMGravity;

@protocol TQDFMNode <NSObject>

@required
- (void)handleAttrs:(NSDictionary *)attrsDict;
- (void)handleInnerText:(NSString *)innerText;

@end

@interface TQDFMElementBase : NSObject <TQDFMNode>

@property (nonatomic,weak) TQDFMLayoutContext* layoutContext; //布局上下文，包括id<TQDFMMessageModel>
@property (nonatomic,weak) TQDFMElementBase* parentElement;
@property (nonatomic,assign) BOOL isUnknownElement;  //标记为未知元素

//元素基本属性
@property (nonatomic, strong) NSString *elementName;
@property (nonatomic, strong) NSMutableDictionary *attributes;
@property (nonatomic, strong) NSString *innerText;
@property (nonatomic, strong) NSMutableArray *subElements;
@property (nonatomic, strong) NSString* elemIndex; //用于标志当前元素在结构化消息树种的位置
@property (nonatomic, assign) CGRect layoutFrame; // 想来想去还是这里加个frame比较好


//通用布局属性
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) CGFloat aspectRatio; //宽高比,在高度/宽度只有一个不确定时，才有效
@property (nonatomic,assign) TQDFMMeasureMode widthMode; //由width转换
@property (nonatomic,assign) TQDFMMeasureMode heightMode; //由height转换
@property (nonatomic,assign) TQDFMGravity gravityHorizontal; //由gravity转换
@property (nonatomic,assign) TQDFMGravity gravityVertical; //由gravity转换
@property (nonatomic,assign) CGFloat weight; //权重值，仅linear容器里有效，用于瓜分剩余布局空间
@property (nonatomic,assign) CGFloat paddingTop; //可由padding转换
@property (nonatomic,assign) CGFloat paddingBottom;
@property (nonatomic,assign) CGFloat paddingLeft;
@property (nonatomic,assign) CGFloat paddingRight;
@property (nonatomic,assign) CGFloat marginTop; //可由margin转换
@property (nonatomic,assign) CGFloat marginBottom;
@property (nonatomic,assign) CGFloat marginLeft;
@property (nonatomic,assign) CGFloat marginRight;

//通用显示属性
@property (nonatomic,strong) NSString* background;
@property (nonatomic,strong) NSString* alpha;
@property (nonatomic,strong) NSString* cornerRadius;
@property (nonatomic,strong) NSString* borderWidth;
@property (nonatomic,strong) NSString* borderColor;

//通用行为属性
@property (nonatomic,strong) NSString* enable; //仅控制是否响应事件，不影响UI显示
@property (nonatomic,strong) NSString* action; //行为类型，父类已定义
@property (nonatomic,strong) NSString* actionData; //行为参数，父类已定义
@property (nonatomic,strong) NSString* successStatus; //行为成功后要切换的消息状态
@property (nonatomic,strong) NSString* failStatus; //行为失败后要切换的消息状态

//可见控制属性
@property (nonatomic,strong) NSString* platform; //描述元素在哪个平台可见
@property (nonatomic,strong) NSString* senderNotShow;
@property (nonatomic,strong) NSString* receiverNotShow;
@property (nonatomic,strong) NSString* maxVersion; //描述元素支持的最大版本，参考TQDFM_VERSION
@property (nonatomic,strong) NSString* minVersion;
@property (nonatomic,strong) NSArray<NSString*>* statusArray; //描述元素在哪种消息状态下可见，由status转换

//辅助存储属性
@property (nonatomic,assign) BOOL isWidthSure; // 布局过程中标记宽度已确定，即当前宽度就是最终的宽度
@property (nonatomic,assign) BOOL isHeightSure;
@property (nonatomic,assign) CGRect layoutFrameBackup; //备份布局结果，用来复用


//辅助计算属性
@property (nonatomic,assign,readonly) BOOL isHiddenForever; 
@property (nonatomic,assign,readonly) BOOL isHidden; //包括永久和临时隐藏
@property (nonatomic,assign) CGFloat layoutFrameX;
@property (nonatomic,assign) CGFloat layoutFrameY;
@property (nonatomic,assign) CGFloat layoutFrameWidth;
@property (nonatomic,assign) CGFloat layoutFrameHeight;

- (instancetype)initWithElementName:(NSString *)elementName;

// 从当前元素开始往上找到第一个某类型的元素，包括当前元素
- (TQDFMElementBase *)findFirstParentElementOfClass:(Class)parentClass;

+ (UIColor *)getColorWithStr:(NSString*)colorStr;

//容器类不复用
- (BOOL)shouldReuse;
// 视图复用的标识
- (NSString *)reuseIdentifier;

- (void)resetLayoutFrame;
- (void)setLayoutFrameForSure:(CGRect)frame;

 //单子元素时，计算子元素最大布局范围（去掉padding）
- (CGSize)getMaxContentSizeWithMaxSize:(CGSize)maxSize;
// 单子元素时，根据padding和gravity计算子元素origin
- (CGPoint)getContentOriginWithContentSize:(CGSize)contentSize maxSize:(CGSize)maxSize;
// 单子元素时，根据包裹内容和padding调整自身大小
- (BOOL)adjustSizeWithWrappedContentSize:(CGSize)contentSize;

// 根据确定的宽或高，以及宽高比来调整自身大小
- (BOOL)adjustSizeByAspectRatio;

// 获取最终的布局大小，不超过maxSize的范围
- (CGSize)getLayoutSizeWithMaxSize:(CGSize)maxSize;

#pragma mark To Override

// 属性已赋值结束，可以进一步处理自身属性，比如组合属性产生新属性
- (void)attributesDidHandle:(NSDictionary *)attrsDict;

// 元素树层次已完成，可以进一步处理子元素
- (void)elementTreeDidBuild;

@end


#pragma mark - SubClass

@interface TQDFMElementMsg: TQDFMElementBase

@property (nonatomic, strong) NSString* brief;          // 结构化消息预览信息
@property (nonatomic, strong) NSString* flag;           // 标志位设置，一个bit表示一个标志，标志位定义见 TQDFMElementMsgFlag

@end


@interface TQDFMElementLinear : TQDFMElementBase

@property (nonatomic,strong) NSString* orientation;

@end

@interface TQDFMElementContainer : TQDFMElementBase

@end

@interface TQDFMElementFold : TQDFMElementBase

@property (nonatomic,strong) NSString* expand;

@end

@interface TQDFMElementDivider : TQDFMElementBase

@property (nonatomic,strong) NSString* style; // 分割线样式，dot表示虚线；父类已定义
@property (nonatomic,strong) NSString* orientation;

@end
