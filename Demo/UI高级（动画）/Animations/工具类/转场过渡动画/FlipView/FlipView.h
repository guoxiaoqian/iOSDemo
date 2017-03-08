//
//  FlipView.h
//  QQingCommon
//
//  Created by Ben on 16/11/4.
//  Copyright (c) 2015年 QQingiOSTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlipDelegate <NSObject>
@optional
- (void)animationDidFinished;
- (void)animationAllFinished;
@end

@interface FlipView : UIView {
    UIImage *_frontImage;
    UIImage *_backImage;
    id<FlipDelegate> __weak _flipDelegate;
}
@property (strong, nonatomic) UIImage *frontImage;
@property (strong, nonatomic) UIImage *backImage;
@property (weak, nonatomic) id<FlipDelegate> flipDelegate;

- (void)flipOpen;
- (void)flipClose;
- (BOOL)isOpen;

@end


