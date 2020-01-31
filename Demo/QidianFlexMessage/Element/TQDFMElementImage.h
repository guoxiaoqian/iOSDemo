//
//  TQDFMElementImage.h
//  QQ
//
//  Created by 郭晓倩 on 2018/11/24.
//

#import "TQDFMElementBase.h"

@interface TQDFMElementImage : TQDFMElementBase

@property (nonatomic,strong) NSString* src;
@property (nonatomic,strong) NSString* icon;

//辅助存储属性
@property (nonatomic,assign) CGRect imageFrame;

+ (UIImage*)getLocalImageWithIconName:(NSString*)iconName;
- (UIImage*)getLocalImage;

@end
