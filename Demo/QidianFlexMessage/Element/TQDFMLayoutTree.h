//
//  TQDFMLayoutTree.h
//  QQ
//
//  Created by 郭晓倩 on 2019/1/12.
//

#import <Foundation/Foundation.h>
#import "TQDFMLayoutContext.h"
#import "TQDFMElementBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface TQDFMLayoutTree : NSObject

@property (nonatomic,strong) TQDFMLayoutContext* layoutContext;
@property (nonatomic,strong) TQDFMElementMsg* elementTree;

- (instancetype)initWithMessageModel:(id<TQDFMMessageModel>)messageModel elementTree:(nullable TQDFMElementMsg*)elementTree;

@end

NS_ASSUME_NONNULL_END
