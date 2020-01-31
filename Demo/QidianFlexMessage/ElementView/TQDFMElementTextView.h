//
//  TQDFMElementTextView.h
//  QQMSFContact
//
//  Created by gavinxqguo on 18/11/20.
//
//

#import "TQDFMElementBaseView.h"

@class TQDFMElementText;

@interface TQDFMElementTextView : TQDFMElementBaseView

+ (CGSize)layoutSpecialQDFMElement:(TQDFMElementText *)baseMsg withMaxSize:(CGSize)maxSize;
- (void)renderSpecialQDFMElement:(TQDFMElementText *)baseMsg;

@end
