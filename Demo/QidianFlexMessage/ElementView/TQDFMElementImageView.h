//
//  TQDFMElementImageView.h
//  QQMSFContact
//
//  Created by gavinxqguo on 18/11/20.
//
//

#import "TQDFMElementBaseView.h"

@class TQDFMElementImage;

@interface TQDFMElementImageView : TQDFMElementBaseView

+ (CGSize)layoutSpecialQDFMElement:(TQDFMElementImage *)baseMsg withMaxSize:(CGSize)maxSize;

- (void)renderSpecialQDFMElement:(TQDFMElementImage *)baseMsg;

@end
