//
//  TQDFMLayoutContext.m
//  QQ
//
//  Created by 郭晓倩 on 2018/11/25.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "TQDFMLayoutContext.h"

@implementation TQDFMLayoutContext

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isDirty = YES;
    }
    return self;
}

@end
