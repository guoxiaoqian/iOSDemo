//
//  AutoCodingModel.h
//  Demo
//
//  Created by 郭晓倩 on 2019/3/27.
//  Copyright © 2019年 郭晓倩. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AutoCodingModel : NSObject<NSCoding>

- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;

@end

NS_ASSUME_NONNULL_END
