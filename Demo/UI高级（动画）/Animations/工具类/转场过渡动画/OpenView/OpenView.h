//
//  OpenView.h
//  QQingCommon
//
//  Created by Ben on 16/11/4.
//  Copyright (c) 2015年 QQingiOSTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlipOpenDelegate <NSObject>
@optional
- (void)animationDidFinished;
@end

@interface OpenView : UIView {
    CGFloat _duration;
    UIImage *_frontImage;
    UIImage *_backImage;
    UIImage *_bottomImage;
    id<FlipOpenDelegate> __weak _flipDelegate;
}
@property (nonatomic) CGFloat duration;
@property (strong, nonatomic) UIImage *frontImage;
@property (strong, nonatomic) UIImage *backImage;
@property (strong, nonatomic) UIImage *bottomImage;
@property (weak, nonatomic) id<FlipOpenDelegate> flipDelegate;

- (void)flipOpen;
- (void)flipClose;
- (void)setBackLayerFrame:(CGRect)rect;
- (void)openState;

@end


