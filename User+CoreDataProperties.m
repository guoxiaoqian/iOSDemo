//
//  User+CoreDataProperties.m
//  Demo
//
//  Created by 郭晓倩 on 17/2/15.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "User+CoreDataProperties.h"

@implementation User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"User"];
}

@dynamic name;

@end
