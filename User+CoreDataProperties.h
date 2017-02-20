//
//  User+CoreDataProperties.h
//  Demo
//
//  Created by 郭晓倩 on 17/2/15.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "User+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
