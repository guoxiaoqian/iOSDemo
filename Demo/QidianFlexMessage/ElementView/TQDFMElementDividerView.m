//
//  TQDFMElementDividerView.m
//  QQ
//
//  Created by 郭晓倩 on 2018/11/21.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


#import "TQDFMElementDividerView.h"
#import "TQDFMElementBase.h"

@interface TQDFMElementDividerView ()

@property (nonatomic,strong) CAShapeLayer *lineLayer;

@end

@implementation TQDFMElementDividerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
    }
    return self;
}

- (CAShapeLayer*)lineLayer {
    if (_lineLayer == nil) {
        _lineLayer = [CAShapeLayer layer];
        [self.layer addSublayer:_lineLayer];
    }
    return _lineLayer;
}

- (void)renderSpecialQDFMElement:(TQDFMElementDivider *)baseMsg {
    
    // 取背景色为线段颜色
    UIColor* lineColor = [TQDFMElementBase getColorWithStr:baseMsg.background];
    if (lineColor == nil) {
        lineColor = [UIColor lightGrayColor];
    }
    
    if ([baseMsg.style isEqualToString:@"dot"]) {
        self.lineLayer.hidden = NO;
        self.backgroundColor = [UIColor clearColor];
        
        CGRect lineBounds = self.bounds;
        CGPoint linePosition = CGPointMake(lineBounds.size.width/2, lineBounds.size.height);
        CGFloat lineWidth = lineBounds.size.height;
        CGPoint lineEndPoint = CGPointMake(lineBounds.size.width, 0);
        CGFloat lineLength = 5;
        CGFloat lineSpacing = 3;
        
        if ([baseMsg.orientation isEqualToString:@"vertical"]) {
            linePosition = CGPointMake(lineBounds.size.width, lineBounds.size.height/2);
            lineWidth = lineBounds.size.width;
            lineEndPoint = CGPointMake(0, lineBounds.size.height);
        }
        
        [self.lineLayer setBounds:lineBounds];
        [self.lineLayer setPosition:linePosition];
        [self.lineLayer setFillColor:[UIColor clearColor].CGColor];
        
        // 设置虚线颜色
        [self.lineLayer setStrokeColor:lineColor.CGColor];
        
        // 设置虚线宽度
        [self.lineLayer setLineWidth:lineWidth];
        [self.lineLayer setLineJoin:kCALineJoinRound];
        
        // 设置线宽，线间距
        [self.lineLayer setLineDashPattern:@[@(lineLength),@(lineSpacing)]];
        
        // 设置路径
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 0, 0);
        CGPathAddLineToPoint(path, NULL, lineEndPoint.x, lineEndPoint.y);
        
        [self.lineLayer setPath:path];
        CGPathRelease(path);
    } else {
        self.lineLayer.hidden = YES;
        self.backgroundColor = lineColor;
    }
}

@end
