//
//  TQDFMElementText.h
//  QQ
//
//  Created by 郭晓倩 on 2018/11/24.
//

#import "TQDFMElementBase.h"

typedef enum : NSUInteger {
    TQDFM_TEXT_STYLE_NORMAL                      = 0,
    TQDFM_TEXT_STYLE_BOLD                        = 1,
    TQDFM_TEXT_STYLE_ITALIC                      = 1 << 1,
    TQDFM_TEXT_STYLE_UNDERLINE                   = 1 << 2,
    TQDFM_TEXT_STYLE_DELETE                      = 1 << 3,
} TQDFMTextStyle;

@interface TQDFMElementText : TQDFMElementBase

@property (nonatomic,strong) NSString* text;
@property (nonatomic,strong) NSString* color;
@property (nonatomic,strong) NSString* size;
@property (nonatomic,strong) NSString* style;
@property (nonatomic,strong) NSString* lineSpaceStr; //父类中已有CGFloat类型的lineSpace,特区分开

@property (nonatomic,strong) NSString* overflow;
@property (nonatomic,strong) NSString* maxLine;
@property (nonatomic,strong) NSString* alignment;

//辅助存储属性
@property (nonatomic,assign) CGRect textFrame;

+ (TQDFMTextStyle)getTextStyleWithStr:(NSString*)styleStr;
+ (UIColor*)getTextColorWithStr:(NSString*)colorStr;
+ (UIFont*)getFontWithSizeStr:(NSString*)sizeStr styleStr:(NSString*)styleStr;
+ (CGFloat)getLineSpaceWithStr:(NSString*)lineSpaceStr;
+ (NSAttributedString*)getAttributedTextWithTextStr:(NSString*)textStr sizeStr:(NSString*)sizeStr styleStr:(NSString*)styleStr colorStr:(NSString*)colorStr lineSpaceStr:(NSString*)lineSpaceStr;

+ (CGSize)getTextSize:(TQDFMElementText *)baseMsg withMaxSize:(CGSize)maxSize;

- (UIFont*)getFont;
- (NSAttributedString*)getAttributedText;

@end
