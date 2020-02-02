//
//  TQDFMElementScrollerView.m
//  Demo
//
//  Created by 郭晓倩 on 2020/2/2.
//  Copyright © 2020 郭晓倩. All rights reserved.
//

#import "TQDFMElementScrollerView.h"
#import "TQDFMElementBase.h"

@interface TQDFMElementScrollerView ()

@property (strong,nonatomic) UIScrollView* scrollView;

@end

@implementation TQDFMElementScrollerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:self.scrollView];
    }
    return self;
}

- (void)renderSpecialQDFMElement:(TQDFMElementScroller *)baseMsg {
    // 滑动视图大小
    self.scrollView.frame = CGRectMake(0,0,baseMsg.layoutFrame.size.width,baseMsg.layoutFrame.size.height);

    // 滑动区域大小
    CGFloat maxXForChild = 0;
    CGFloat maxYForChild = 0;
    for (TQDFMElementBase* child in baseMsg.subElements) {
        maxXForChild = MAX(maxXForChild,CGRectGetMaxX(child.layoutFrame));
        maxYForChild = MAX(maxYForChild,CGRectGetMaxY(child.layoutFrame));
    }
    self.scrollView.contentSize = CGSizeMake(maxXForChild,maxYForChild);
}

- (UIView*)contentViewToRenderChildren {
    return self.scrollView;
}

@end
