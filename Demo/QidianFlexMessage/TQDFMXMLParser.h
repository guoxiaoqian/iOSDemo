//
//  TQDFMXMLParser.h
//  Demo
//
//  Created by 郭晓倩 on 2020/1/31.
//  Copyright © 2020 郭晓倩. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TQDFMElementMsg;

@interface TQDFMXMLParser : NSObject

- (TQDFMElementMsg*)parseByString:(NSString*)xml;

@end

NS_ASSUME_NONNULL_END
