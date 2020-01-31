//
//  TQDFMElementLoadingHolderView.m
//  Demo
//
//  Created by 郭晓倩 on 2020/1/31.
//  Copyright © 2020 郭晓倩. All rights reserved.
//

#import "TQDFMElementLoadingHolderView.h"
#import "TQDFMElementBase.h"

#define HOLDER_MSG_TOTAL_H 75
#define HOLDER_TEXT_FONT_SIZE 14
#define HOLDER_ICON_WIDTH 23.5
#define HOLDER_ICON_HEIGHT 22.5
#define HOLDER_ICON_LEFT_MARGIN 7.5

@interface TQDFMElementLoadingHolderView ()

@property (strong,nonatomic) UIImageView* iconView;
@property (strong,nonatomic) UILabel* textLabel;

@end

@implementation TQDFMElementLoadingHolderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        _textLabel.textColor = [UIColor grayColor];
        _textLabel.font = [UIFont systemFontOfSize:HOLDER_TEXT_FONT_SIZE];
        
        [self addSubview:_iconView];
        [self addSubview:_textLabel];
    }
    return self;
}

+ (CGSize)layoutSpecialQDFMElement:(TQDFMElementLoadingHolder *)baseMsg withMaxSize:(CGSize)maxSize {
    
    if ([baseMsg isKindOfClass:[TQDFMElementLoadingHolder class]] == NO) {
        return CGSizeZero;
    }
    
    CGSize contentSize = CGSizeMake(maxSize.width, HOLDER_MSG_TOTAL_H);
    // STEP3: 处理自身未确定的宽和高（Wrap）
    [baseMsg adjustSizeWithWrappedContentSize:contentSize];
    
    return baseMsg.layoutFrame.size;
}

- (void)renderSpecialQDFMElement:(TQDFMElementLoadingHolder *)baseMsg
{
    if ([baseMsg isKindOfClass:[TQDFMElementLoadingHolder class]] == NO) {
        return;
    }
    
    TQDFMElementLoadingHolder* elementHolder = (TQDFMElementLoadingHolder*)baseMsg;
    
    CGFloat msgWidth = baseMsg.layoutFrame.size.width;
    if (elementHolder.loadStatus == TQDFMMessageLoadStatus_NotLoad ) {
        _textLabel.text = @"消息正在下载中，请稍等~";
        CGSize textSize = [_textLabel.text boundingRectWithSize:CGSizeMake(msgWidth - HOLDER_ICON_WIDTH - HOLDER_ICON_LEFT_MARGIN, HOLDER_MSG_TOTAL_H) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_textLabel.font} context:nil].size;
        
        _textLabel.frame = CGRectMake((msgWidth + HOLDER_ICON_WIDTH + HOLDER_ICON_LEFT_MARGIN - textSize.width)/2, (HOLDER_MSG_TOTAL_H - textSize.height)/2, textSize.width, textSize.height);
        
        _iconView.image = [[TQDFMPlatformBridge sharedInstance] getBundleImageWithPath:@"longmsgloading.png"];
        _iconView.frame = CGRectMake((msgWidth - HOLDER_ICON_WIDTH - HOLDER_ICON_LEFT_MARGIN - textSize.width)/2, (HOLDER_MSG_TOTAL_H - HOLDER_ICON_HEIGHT)/2, HOLDER_ICON_WIDTH, HOLDER_ICON_HEIGHT);
    }
    else if (elementHolder.loadStatus == TQDFMMessageLoadStatus_Fail) {
        _textLabel.text = @"消息下载失败";
        CGSize textSize = [_textLabel.text boundingRectWithSize:CGSizeMake(msgWidth - HOLDER_ICON_WIDTH - HOLDER_ICON_LEFT_MARGIN, HOLDER_MSG_TOTAL_H) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_textLabel.font} context:nil].size;
        
        _textLabel.frame = CGRectMake((msgWidth + HOLDER_ICON_WIDTH + HOLDER_ICON_LEFT_MARGIN - textSize.width)/2, (HOLDER_MSG_TOTAL_H - textSize.height)/2, textSize.width, textSize.height);
        
        _iconView.image = [[TQDFMPlatformBridge sharedInstance] getBundleImageWithPath:@"longmsgfail.png"];
        _iconView.frame = CGRectMake((msgWidth - HOLDER_ICON_WIDTH - HOLDER_ICON_LEFT_MARGIN - textSize.width)/2, (HOLDER_MSG_TOTAL_H - HOLDER_ICON_HEIGHT)/2, HOLDER_ICON_WIDTH, HOLDER_ICON_HEIGHT);
    }
    else {
        
    }
    
}

@end
