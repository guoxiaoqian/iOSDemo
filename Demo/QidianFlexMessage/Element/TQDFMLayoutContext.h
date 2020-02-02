//
//  TQDFMLayoutContext.h
//  QQ
//
//  Created by 郭晓倩 on 2018/11/25.
//

#import <Foundation/Foundation.h>

@protocol TQDFMMessageDataSource;
@protocol TQDFMMessageUIDelegate;
@class TQDFMElementMsg;

@interface TQDFMLayoutContext : NSObject

@property (nonatomic,weak) id<TQDFMMessageUIDelegate> uiDelegate;
@property (nonatomic,strong) id<TQDFMMessageDataSource> msgModel;
@property (nonatomic,assign) BOOL isDirty;
@property (nonatomic,assign) BOOL isHolder; //是否为占位内容，如“正在下载”“下载失败”
@property (nonatomic,assign) BOOL isExpired;
@property (nonatomic,strong) NSString* status;

@end
