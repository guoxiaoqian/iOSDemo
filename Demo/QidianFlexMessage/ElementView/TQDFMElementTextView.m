//
//  TQDFMElementTextView.m
//  QQMSFContact
//
//  Created by gavinxqguo on 18/11/20.
//
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "TQDFMElementTextView.h"
#import "TQDFMElementText.h"

@interface TQDFMElementTextView ()

@property (nonatomic, strong) UILabel *normalLabel;

@end

@implementation TQDFMElementTextView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 用来显示普通文本
        _normalLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _normalLabel.userInteractionEnabled = YES;
        [self addSubview:_normalLabel];
    }
    return self;
}

#pragma mark - Special Layout & Render

+ (CGSize)layoutSpecialQDFMElement:(TQDFMElementText *)baseMsg withMaxSize:(CGSize)maxSize {
    
    // STEP1:测量文本大小
    CGSize maxContentSize = [baseMsg getMaxContentSizeWithMaxSize:maxSize];
    CGSize contentSize = [TQDFMElementText getTextSize:baseMsg withMaxSize:maxContentSize];
    
    // STEP2:布局文本
    CGPoint contentOrigin = [baseMsg getContentOriginWithContentSize:contentSize maxSize:maxSize];
    baseMsg.textFrame = CGRectMake(contentOrigin.x, contentOrigin.y, contentSize.width, contentSize.height);
    
    // STEP3: 处理自身未确定的宽和高（Wrap）
    [baseMsg adjustSizeWithWrappedContentSize:contentSize];
    
    return baseMsg.layoutFrame.size;
}

- (void)renderSpecialQDFMElement:(TQDFMElementText *)baseMsg {
    
    // 调整文本frame
    _normalLabel.frame = baseMsg.textFrame;
    
    _normalLabel.attributedText = [baseMsg getAttributedText];
    
    int numberOfLines = 0;
    if (baseMsg.maxLine && baseMsg.maxLine.intValue > 0) {
        numberOfLines = baseMsg.maxLine.intValue;
    }
    _normalLabel.numberOfLines = numberOfLines;

    _normalLabel.lineBreakMode = NSLineBreakByWordWrapping;
    if ([baseMsg.overflow isEqualToString:@"clip"]) {
        _normalLabel.lineBreakMode |= NSLineBreakByClipping;
    } else {
        _normalLabel.lineBreakMode |= NSLineBreakByTruncatingTail;
    }
    
    NSTextAlignment textAlignment = NSTextAlignmentLeft;
    if (baseMsg.alignment) {
        if ([baseMsg.alignment isEqualToString:@"right"]) {
            textAlignment = NSTextAlignmentRight;
        } else if ([baseMsg.alignment isEqualToString:@"center"]) {
            textAlignment = NSTextAlignmentCenter;
        }
    }
    _normalLabel.textAlignment = textAlignment;
}

@end
