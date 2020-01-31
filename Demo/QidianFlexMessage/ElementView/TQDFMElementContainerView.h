//
//  TQDFMElementFrameView.h
//  QQ
//
//  Created by 郭晓倩 on 2018/11/21.
//

#import "TQDFMElementBaseView.h"

@class TQDFMElementContainer;

@interface TQDFMElementContainerView : TQDFMElementBaseView

+ (CGSize)layoutSpecialQDFMElement:(TQDFMElementContainer *)baseMsg withMaxSize:(CGSize)maxSize;

@end
