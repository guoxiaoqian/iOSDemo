//
//  TQDFMElementText.m
//  QQ
//
//  Created by 郭晓倩 on 2018/11/24.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "TQDFMElementText.h"



@interface TQDFMElementText ()

@property (nonatomic,strong) NSAttributedString* attrText;  //为了复用

@end

@implementation TQDFMElementText

- (instancetype)initWithElementName:(NSString *)elementName {
    if (self = [super initWithElementName:elementName]) {
        _textFrame = CGRectZero;
    }
    return self;
}

- (void)setLineSpace:(CGFloat)lineSpace {
    _lineSpaceStr = @(TQDFM_HEIGHT_FROM_PIXEL(lineSpace)).stringValue;
}

+ (TQDFMTextStyle)getTextStyleWithStr:(NSString*)valueStr {
    TQDFMTextStyle textStyle = TQDFM_TEXT_STYLE_NORMAL;
    NSArray* valueArray = [valueStr componentsSeparatedByString:@"|"];
    if ([valueArray containsObject:@"bold"]) {
        textStyle |= TQDFM_TEXT_STYLE_BOLD;
    } else if ([valueArray containsObject:@"italic"]) {
        textStyle |= TQDFM_TEXT_STYLE_ITALIC;
    } else if([valueArray containsObject:@"underline"]) {
        textStyle |= TQDFM_TEXT_STYLE_UNDERLINE;
    } else if([valueArray containsObject:@"delete"]) {
        textStyle |= TQDFM_TEXT_STYLE_DELETE;
    }
    return textStyle;
}

+ (CGFloat)getFontSizeWithStr:(NSString*)sizeStr {
    CGFloat fontSize = 0;
    if (sizeStr && sizeStr.floatValue > 0) {
        fontSize = TQDFM_FONTSIZE_FROM_PIXEL(sizeStr.floatValue);
    } else {
        fontSize = [[TQDFMPlatformBridge sharedInstance] defaultFontSize];
    }
    return fontSize;
}

+ (UIColor*)getTextColorWithStr:(NSString*)colorStr {
    UIColor* color = [self getColorWithStr:colorStr];
    if (color == nil) {
        color = [[TQDFMPlatformBridge sharedInstance] defaultFontColor];
    }
    return color;
}

+ (UIFont*)getFontWithSizeStr:(NSString*)sizeStr styleStr:(NSString*)styleStr {
    TQDFMTextStyle textStyle = [self getTextStyleWithStr:styleStr];
    CGFloat fontSize = [self getFontSizeWithStr:sizeStr];
    BOOL isBold = textStyle & TQDFM_TEXT_STYLE_BOLD;
    BOOL isItalic = textStyle & TQDFM_TEXT_STYLE_ITALIC;
    if (isBold && isItalic) {
        return [UIFont fontWithName:@"Arial-BoldItalicMT" size:fontSize];
    } else if( isBold) {
        return [UIFont boldSystemFontOfSize:fontSize];
    } else if( isItalic) {
        return [UIFont italicSystemFontOfSize:fontSize];
    } else {
        return [UIFont systemFontOfSize:fontSize];
    }
}

+ (CGFloat)getLineSpaceWithStr:(NSString*)lineSpaceStr {
    if (lineSpaceStr && lineSpaceStr.floatValue > 0) {
        return TQDFM_HEIGHT_FROM_PIXEL(lineSpaceStr.floatValue);
    } else {
        return [NSParagraphStyle defaultParagraphStyle].lineSpacing;
    }
}

+ (NSAttributedString*)getAttributedTextWithTextStr:(NSString*)textStr sizeStr:(NSString*)sizeStr styleStr:(NSString*)styleStr colorStr:(NSString*)colorStr lineSpaceStr:(NSString*)lineSpaceStr{
    
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:textStr ?:@""];
    NSMutableDictionary* attributeDic = [NSMutableDictionary new];
    UIFont* font = [self getFontWithSizeStr:sizeStr styleStr:styleStr];
    [attributeDic setObject:font forKey:NSFontAttributeName];
    UIColor* color = [self getTextColorWithStr:colorStr];
    [attributeDic setObject:color forKey:NSForegroundColorAttributeName];
    
    TQDFMTextStyle textStyle = [self getTextStyleWithStr:styleStr];
    if (textStyle & TQDFM_TEXT_STYLE_UNDERLINE) {
        [attributeDic setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
    }
    if (textStyle & TQDFM_TEXT_STYLE_DELETE) {
        [attributeDic setObject:@(NSUnderlineStyleSingle) forKey:NSStrikethroughStyleAttributeName];
    }
    
    CGFloat lineSpace = [self getLineSpaceWithStr:lineSpaceStr];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing:lineSpace];
    [attributeDic setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    [attrStr setAttributes:attributeDic range:NSMakeRange(0, attrStr.length)];
    
    return attrStr;
}

- (UIFont*)getFont {
    return [[self class] getFontWithSizeStr:self.size styleStr:self.style];
}

- (NSAttributedString*)getAttributedText {
#if TQDFM_REUSE_TEXT
    if (!_attrText) {
        _attrText = [[self class] getAttributedTextWithTextStr:self.text sizeStr:self.size styleStr:self.style colorStr:self.color lineSpaceStr:self.lineSpaceStr];
    }
    return _attrText;
#else
    return [[self class] getAttributedTextWithTextStr:self.text sizeStr:self.size styleStr:self.style colorStr:self.color lineSpaceStr:self.lineSpaceStr];
#endif
}

+ (CGSize)getTextSize:(TQDFMElementText *)baseMsg withMaxSize:(CGSize)maxSize {
    
    CGFloat lineSpace = [self getLineSpaceWithStr:baseMsg.lineSpaceStr];
    UIFont* font = [baseMsg getFont];
    CGFloat singleLineHeight = font.lineHeight + lineSpace;
    NSAttributedString* attributeStr = [baseMsg getAttributedText];
    
    int numberOfLines = 0;
    if (baseMsg.maxLine && baseMsg.maxLine.intValue > 0) {
        numberOfLines = baseMsg.maxLine.intValue;
    }
    
    if (numberOfLines > 0) {
        maxSize.height = MIN(maxSize.height, ceilf(singleLineHeight * numberOfLines));
    }
    
    CGSize layoutSize = [attributeStr boundingRectWithSize:CGSizeMake(maxSize.width, maxSize.height) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingTruncatesLastVisibleLine context:nil].size;
    
    // 减去单行时多余的行间距
    if (layoutSize.height > font.lineHeight && layoutSize.height < singleLineHeight + 1) {
        layoutSize.height = MAX(font.lineHeight, layoutSize.height - lineSpace);
    }
    
    return layoutSize;
}

@end
