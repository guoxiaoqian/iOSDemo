//
//  TQDFMElementFoldView.h
//  QQ
//
//  Created by 郭晓倩 on 2018/11/21.
//

#import "TQDFMElementBaseView.h"

@class TQDFMElementFold;

@interface TQDFMElementFoldView : TQDFMElementBaseView

+ (CGSize)layoutSpecialQDFMElement:(TQDFMElementFold *)baseMsg withMaxSize:(CGSize)maxSize;

@end
