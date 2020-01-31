//
//  TQDFMElementBase.m
//  QQMSFContact
//
//  Created by gavinxqguo on 18/11/20.
//
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "TQDFMElementBase.h"

@interface TQDFMElementBase ()

@property (strong,nonatomic) NSMutableDictionary* platformAttributeDic; // 暂存平台专有属性
@property (strong,nonatomic) NSString* reuseIdentifier;

@end

@implementation TQDFMElementBase

-(instancetype)initWithElementName:(NSString*)elementName {
    if (self = [self init]) {
        _elementName = elementName;
        
        _width = 0;
        _height = 0;
        _aspectRatio = 0;
        _widthMode = TQDFM_MEASURE_WRAP_CONTENT;
        _heightMode = TQDFM_MEASURE_WRAP_CONTENT;
        _gravityHorizontal = TQDFM_GRAVITY_LEFT;
        _gravityVertical = TQDFM_GRAVITY_TOP;
        _weight = 0;
        _paddingTop = 0;
        _paddingBottom = 0;
        _paddingLeft = 0;
        _paddingRight = 0;
        _marginTop = 0;
        _marginBottom = 0;
        _marginLeft = 0;
        _marginRight = 0;
        
        _isWidthSure = NO;
        _isHeightSure = NO;
        _layoutFrameBackup = CGRectZero;
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"element:%@ index:%@ attributes:%@",self.elementName,self.elemIndex,self.attributes];
}

#pragma mark - 通用属性处理

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([value isKindOfClass:[NSString class]] == NO) {
        return;
    }
    NSString* valueStr = (NSString*)value;
    
    if ([key isEqualToString:@"gravity"]) {
        
        NSArray* valueArray = [valueStr componentsSeparatedByString:@"|"];
        if (valueArray.count != 1 && valueArray.count != 2) {
            TQDFM_INFOP_ASSERT_ELEMENT(self, ([NSString stringWithFormat:@"gravity invalid (%@)",valueStr]) );
        }
        if ([valueArray containsObject:@"left"]) {
            _gravityHorizontal = TQDFM_GRAVITY_LEFT;
        } else if ([valueArray containsObject:@"right"]) {
            _gravityHorizontal = TQDFM_GRAVITY_RIGHT;
        } else if([valueArray containsObject:@"centerHorizontal"] || [valueArray containsObject:@"center"]) {
            _gravityHorizontal = TQDFM_GRAVITY_CENTER_HORIZONTAL;
        }
        
        if ([valueArray containsObject:@"top"]) {
            _gravityVertical = TQDFM_GRAVITY_TOP;
        } else if ([valueArray containsObject:@"bottom"]) {
            _gravityVertical = TQDFM_GRAVITY_BOTTOM;
        } else if ([valueArray containsObject:@"centerVertical"] || [valueArray containsObject:@"center"]){
            _gravityVertical = TQDFM_GRAVITY_CENTER_VERTICAL;
        }
    } else if ([key isEqualToString:@"padding"]) {
        
        NSArray* valueArray = [valueStr componentsSeparatedByString:@","];
        if (valueArray.count != 1 && valueArray.count != 4) {
            TQDFM_INFOP_ASSERT_ELEMENT(self, ([NSString stringWithFormat:@"padding invalid (%@)",valueStr]) );
        }
        
        if (valueArray.count == 1) {
            self.paddingLeft = self.paddingTop = self.paddingRight = self.paddingBottom = [valueArray[0] floatValue];
        } else {
            for (int i=0; i < valueArray.count; ++i) {
                CGFloat valueItem = [valueArray[i] floatValue];
                switch (i) {
                    case 0:
                        self.paddingLeft = valueItem;
                        break;
                    case 1:
                        self.paddingTop = valueItem;
                        break;
                    case 2:
                        self.paddingRight = valueItem;
                        break;
                    case 3:
                        self.paddingBottom = valueItem;
                        break;
                    default:
                        break;
                }
            }
        }
    } else if ([key isEqualToString:@"margin"]) {
        NSArray* valueArray = [valueStr componentsSeparatedByString:@","];
        if (valueArray.count != 1 && valueArray.count != 4) {
            TQDFM_INFOP_ASSERT_ELEMENT(self, ([NSString stringWithFormat:@"margin invalid (%@)",valueStr]));
        }
        
        if (valueArray.count == 1) {
            self.marginLeft = self.marginTop = self.marginRight = self.marginBottom = [valueArray[0] floatValue];
        } else {
            
            for (int i=0; i < valueArray.count; ++i) {
                CGFloat valueItem = [valueArray[i] floatValue];
                switch (i) {
                    case 0:
                        self.marginLeft = valueItem;
                        break;
                    case 1:
                        self.marginTop = valueItem;
                        break;
                    case 2:
                        self.marginRight = valueItem;
                        break;
                    case 3:
                        self.marginBottom = valueItem;
                        break;
                    default:
                        break;
                }
            }
        }
    } else if([key isEqualToString:@"status"]) {
        _statusArray = [valueStr componentsSeparatedByString:@"|"];
    } else {
        
        // 属性级别的平台兼容能力
        NSArray* keyArray = [key componentsSeparatedByString:@"."];
        if (keyArray.count == 2) {
            NSString* platform = keyArray[1];
            if([platform isEqualToString:@"ios"] || [platform isEqualToString:@"mobile"]) {
                if (_platformAttributeDic == nil) {
                    _platformAttributeDic = [NSMutableDictionary new];
                }
                [_platformAttributeDic setObject:value forKey:keyArray[0]];
            }
        }
        
    }
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}

#pragma mark - 特殊属性处理

- (void)setWidth:(CGFloat)width {
    if (width < 0) {
        _width = 0;
        if ((int)width == -1) {
            _widthMode = TQDFM_MEASURE_MATCH_PARRENT;
        } else if ((int)width == -2) {
            _widthMode = TQDFM_MEASURE_WRAP_CONTENT;
        } else {
            TQDFM_INFOP_ASSERT_ELEMENT(self, @"width invalid");
            _widthMode = TQDFM_MEASURE_EXACTLY;
        }
    } else {
        _width =  TQDFM_WIDTH_FROM_PIXEL(width);
        _widthMode = TQDFM_MEASURE_EXACTLY;
    }
}

- (void)setHeight:(CGFloat)height {
    if (height < 0) {
        _height = 0;
        if ((int)height == -1) {
            _heightMode = TQDFM_MEASURE_MATCH_PARRENT;
        } else if ((int)height == -2) {
            _heightMode = TQDFM_MEASURE_WRAP_CONTENT;
        } else {
            TQDFM_INFOP_ASSERT_ELEMENT(self, @"height invalid");
            _heightMode = TQDFM_MEASURE_EXACTLY;
        }
    } else {
        _height = TQDFM_HEIGHT_FROM_PIXEL(height);
        _heightMode = TQDFM_MEASURE_EXACTLY;
    }
}

- (void)setPaddingTop:(CGFloat)paddingTop {
    _paddingTop = TQDFM_HEIGHT_FROM_PIXEL(paddingTop);
}

- (void)setPaddingBottom:(CGFloat)paddingBottom{
    _paddingBottom = TQDFM_HEIGHT_FROM_PIXEL(paddingBottom);
}

- (void)setPaddingLeft:(CGFloat)paddingLeft {
    _paddingLeft = TQDFM_WIDTH_FROM_PIXEL(paddingLeft);
}

- (void)setPaddingRight:(CGFloat)paddingRight{
    _paddingRight = TQDFM_WIDTH_FROM_PIXEL(paddingRight);
}

- (void)setMarginTop:(CGFloat)marginTop {
    _marginTop = TQDFM_HEIGHT_FROM_PIXEL(marginTop);
}

- (void)setMarginBottom:(CGFloat)marginBottom {
    _marginBottom = TQDFM_HEIGHT_FROM_PIXEL(marginBottom);
}

- (void)setMarginLeft:(CGFloat)marginLeft {
    _marginLeft = TQDFM_WIDTH_FROM_PIXEL(marginLeft);
}

- (void)setMarginRight:(CGFloat)marginRight {
    _marginRight = TQDFM_WIDTH_FROM_PIXEL(marginRight);
}

#pragma mark - 可变属性保护

- (void)setSubElements:(NSMutableArray *)subElements {
    if (subElements == nil || [subElements isKindOfClass:[NSMutableArray class]]) {
        _subElements = subElements;
    } else if ([subElements isKindOfClass:[NSArray class]]) {
        _subElements = [subElements mutableCopy];
    }
}

- (void)setAttributes:(NSMutableDictionary *)attributes {
    if (attributes == nil || [attributes isKindOfClass:[NSMutableDictionary class]]) {
        _attributes = attributes;
    } else if ([attributes isKindOfClass:[NSDictionary class]]) {
        _attributes = [attributes mutableCopy];
    }
}

#pragma mark - 辅助计算属性

- (BOOL)isHiddenForever {
    if (_platform && !([_platform isEqualToString:@"ios"] || [_platform isEqualToString:@"mobile"])) {
        return YES;
    }
    
    if (_senderNotShow && [_senderNotShow boolValue] && self.layoutContext.msgModel.isFMSender == YES) {
        return YES;
    }
    
    if (_receiverNotShow && [_receiverNotShow boolValue] && self.layoutContext.msgModel.isFMSender == NO) {
        return YES;
    }
    
    if (_minVersion && _minVersion.intValue > 0 && _minVersion.intValue > TQDFM_VERSION) {
        return YES;
    }
    
    if (_maxVersion && _maxVersion.intValue > 0 && _maxVersion.intValue < TQDFM_VERSION) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isHidden {
    if([self isHiddenForever]) {
        return YES;
    }
    
    //有状态属性，且值不包含整体消息状态时，则不显示
    if (_statusArray.count > 0 && self.layoutContext.status && [_statusArray containsObject:self.layoutContext.status] == NO) {
        return YES;
    }
    
    return NO;
}

- (CGFloat)layoutFrameX {
    return self.layoutFrame.origin.x;
}

- (CGFloat)layoutFrameY {
    return self.layoutFrame.origin.y;
}

- (CGFloat)layoutFrameWidth {
    return self.layoutFrame.size.width;
}

- (CGFloat)layoutFrameHeight {
    return self.layoutFrame.size.height;
}

- (void)setLayoutFrameX:(CGFloat)x {
    CGRect frame = self.layoutFrame;
    frame.origin.x = x;
    self.layoutFrame = frame;
}

- (void)setLayoutFrameY:(CGFloat)y {
    CGRect frame = self.layoutFrame;
    frame.origin.y = y;
    self.layoutFrame = frame;
}

- (void)setLayoutFrameWidth:(CGFloat)width {
    CGRect frame = self.layoutFrame;
    frame.size.width = width;
    self.layoutFrame = frame;
    self.isWidthSure = YES;
}

- (void)setLayoutFrameHeight:(CGFloat)height {
    CGRect frame = self.layoutFrame;
    frame.size.height = height;
    self.layoutFrame = frame;
    self.isHeightSure = YES;
}

#pragma mark - Public

+ (UIColor *)getColorWithStr:(NSString*)colorStr
{
    unsigned int intColor = 0;
    if ([colorStr hasPrefix:@"#"]) {
        intColor = (unsigned int)strtoul([[colorStr substringFromIndex:1] UTF8String], NULL, 16);
    }else if ([colorStr.lowercaseString hasPrefix:@"0x"]) {
        intColor = (unsigned int)strtoul([[colorStr substringFromIndex:2] UTF8String], NULL, 16);
    } else {
        return nil;
    }
    
    float red = ((float)((intColor & 0x00FF0000) >> 16))/0xFF;
    float green = ((float)((intColor & 0x0000FF00) >> 8))/0xFF;
    float blue = ((float)(intColor & 0x000000FF))/0xFF;
    float alpha = 1;
    if (colorStr.length >= 9) {
        alpha  = ((float)((intColor & 0xFF000000) >> 24))/0xFF;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (TQDFMElementBase *)findFirstParentElementOfClass:(Class)parentClass {
    TQDFMElementBase *parent = self;
    while (parent != nil) {
        if ([parent isKindOfClass: parentClass]) {
            return parent;
        }
        if ([parent respondsToSelector:@selector(parentElement)] == NO) {
            break;
        }
        parent = [parent performSelector:@selector(parentElement)];
    }
    return nil;
}

- (BOOL)shouldReuse {
#if TQDFM_REUSE_VIEW
    return self.subElements.count == 0;
#else
    return NO;
#endif
}

- (NSString *)reuseIdentifier {
    if(_reuseIdentifier == nil) {
        _reuseIdentifier = [NSString stringWithFormat:@"TQDFM_%@",self.elementName];
    }
    return _reuseIdentifier;
}

- (void)resetLayoutFrame {
    self.layoutFrame = CGRectZero;
    self.isWidthSure = NO;
    self.isHeightSure = NO;
}

- (void)setLayoutFrameForSure:(CGRect)frame {
    self.layoutFrame = frame;
    self.isWidthSure = YES;
    self.isHeightSure = YES;
}

- (CGSize)getMaxContentSizeWithMaxSize:(CGSize)maxSize {
    CGSize maxSizeWithoutPadding = CGSizeMake(maxSize.width - self.paddingLeft - self.paddingRight, maxSize.height - self.paddingTop - self.paddingBottom);
    if (TQDFM_FLOAT_LESS_EQUAL_ZERO(maxSizeWithoutPadding.width) || TQDFM_FLOAT_LESS_EQUAL_ZERO(maxSizeWithoutPadding.height)) {
        return CGSizeZero;
    }
    return maxSizeWithoutPadding;
}

- (CGPoint)getContentOriginWithContentSize:(CGSize)contentSize maxSize:(CGSize)maxSize{
    CGFloat contentX = 0, contentY = 0;
    switch (self.gravityHorizontal) {
        case TQDFM_GRAVITY_LEFT:
            contentX = self.paddingLeft;
            break;
        case TQDFM_GRAVITY_RIGHT:
            contentX = maxSize.width - self.paddingRight - contentSize.width;
            break;
        case TQDFM_GRAVITY_CENTER_HORIZONTAL:{
            contentX = self.paddingLeft + (maxSize.width - self.paddingLeft - self.paddingRight - contentSize.width) / 2;
        }
            break;
        default:
            break;
    }
    
    switch (self.gravityVertical) {
        case TQDFM_GRAVITY_TOP:
            contentY = self.paddingTop;
            break;
        case TQDFM_GRAVITY_BOTTOM:
            contentY = maxSize.height - self.paddingBottom - contentSize.height;
            break;
        case TQDFM_GRAVITY_CENTER_VERTICAL:
            contentY = self.paddingTop + (maxSize.height - self.paddingTop - self.paddingBottom - contentSize.height) / 2;
            break;
        default:
            break;
    }
    
    return CGPointMake(contentX, contentY);
}

- (BOOL)adjustSizeWithWrappedContentSize:(CGSize)contentSize {
    BOOL isAdjusted = NO;
    if (self.isWidthSure == NO && self.widthMode == TQDFM_MEASURE_WRAP_CONTENT) {
        [self setLayoutFrameWidth:contentSize.width + self.paddingLeft + self.paddingRight];
        isAdjusted = YES;
    }
    if (self.isHeightSure == NO && self.heightMode == TQDFM_MEASURE_WRAP_CONTENT) {
        [self setLayoutFrameHeight:contentSize.height + self.paddingTop + self.paddingBottom];
        isAdjusted = YES;
    }
    return isAdjusted;
}

- (BOOL)adjustSizeByAspectRatio {
    if (self.aspectRatio > 0) {
        if (self.isWidthSure == YES && self.isHeightSure == NO) {
            [self setLayoutFrameHeight:self.layoutFrame.size.width / self.aspectRatio];
            return YES;
        } else if (self.isWidthSure == NO && self.isHeightSure == YES) {
            [self setLayoutFrameWidth:self.layoutFrame.size.height * self.aspectRatio];
            return YES;
        }
    }
    return NO;
}


- (CGSize)getLayoutSizeWithMaxSize:(CGSize)maxSize {
    return CGSizeMake(MIN(maxSize.width, self.layoutFrame.size.width), MIN(maxSize.height, self.layoutFrame.size.height));
}

//MARK: Parse Node

- (void)handleAttrs:(NSDictionary *)attrsDict
{
    self.attributes = [attrsDict mutableCopy];
    [self setValuesForKeysWithDictionary:attrsDict];
    
    [self attributesDidHandle:attrsDict];
}

- (void)handleInnerText:(NSString *)innerText
{
    self.innerText = innerText;
}

//MARK: To Override

- (void)attributesDidHandle:(NSDictionary *)attrsDict {
    
    // 处理当前平台专有属性，覆盖同名通用属性
    [self setValuesForKeysWithDictionary:_platformAttributeDic];
    _platformAttributeDic = nil;
    
    // 通过weight和width/height调整测量模式
    if (self.weight > 0) {
        if (self.width == 0) {
            self.widthMode = TQDFM_MEASURE_MATCH_PARRENT;
        } else if (self.height == 0) {
            self.heightMode = TQDFM_MEASURE_MATCH_PARRENT;
        } else {
            TQDFM_INFOP_ASSERT_ELEMENT(self,@"weight invalid");
        }
    }
}

- (void)elementTreeDidBuild {
    // 子类实现
}

@end

@implementation TQDFMElementMsg: TQDFMElementBase

@end

@implementation TQDFMElementLinear

-(instancetype)initWithElementName:(NSString*)elementName {
    if (self = [super initWithElementName:elementName]) {
        _orientation = @"horizontal";
    }
    return self;
}

@end

@implementation TQDFMElementContainer

@end

@implementation TQDFMElementFold

- (void)elementTreeDidBuild {
    [super elementTreeDidBuild];
    
    //给头部元素加入expand事件
    if(self.subElements.count >= 2) {
        TQDFMElementBase* firstChild = self.subElements[0];
        if (firstChild.action.length == 0) {
            firstChild.action = @"expand";
        }
        
        TQDFMElementBase* secondChild = self.subElements[1];
        TQDFMElementBase* secondChildChild = nil;
        if (secondChild.subElements.count) {
            secondChildChild = secondChild.subElements[0];
        }
        if (secondChildChild.action.length == 0) {
            secondChildChild.action = @"expand";
        }
    }
}

@end


@implementation TQDFMElementDivider

-(id)initWithElementName:(NSString *)elementName {
    if (self = [super initWithElementName:elementName]) {
        self.background = @"#FFE2E6ED";
    }
    return self;
}


@end

@implementation TQDFMElementLoadingHolder

@end

