//
//  NSManagedObjectModel+MagicalRecord.m
//
//  Created by Saul Mora on 3/11/10.
//  Copyright 2010 Magical Panda Software, LLC All rights reserved.
//

//#import "NSManagedObjectModel+MagicalRecord.h"
#import "CoreData+MagicalRecord.h"


static NSManagedObjectModel *defaultManagedObjectModel_ = nil;

// Now we just support single Bundle
static NSBundle *specifiedBundle_ = nil;

@implementation NSManagedObjectModel (MagicalRecord)

+ (NSManagedObjectModel *) MR_defaultManagedObjectModel
{
	if (defaultManagedObjectModel_ == nil && [MagicalRecord shouldAutoCreateManagedObjectModel])
	{
        [self MR_setDefaultManagedObjectModel:[self MR_mergedObjectModelFromMainBundle]];
	}
	return defaultManagedObjectModel_;
}

+ (void) MR_setDefaultManagedObjectModel:(NSManagedObjectModel *)newDefaultModel
{
	defaultManagedObjectModel_ = newDefaultModel;
}

+ (NSManagedObjectModel *) MR_mergedObjectModelFromMainBundle;
{
    return [self mergedModelFromBundles:( specifiedBundle_ ? @[specifiedBundle_, [NSBundle mainBundle]] : nil)];
}

+ (NSManagedObjectModel *) MR_newModelNamed:(NSString *) modelName inBundleNamed:(NSString *) bundleName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:[modelName stringByDeletingPathExtension] 
                                                     ofType:[modelName pathExtension] 
                                                inDirectory:bundleName];
    
    if (specifiedBundle_)
    {
        path = [specifiedBundle_ pathForResource:[modelName stringByDeletingPathExtension]
                                               ofType:[modelName pathExtension]
                                          inDirectory:bundleName];
    }
    
    NSURL *modelUrl = [NSURL fileURLWithPath:path];
    
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
    
    return mom;
}

+ (NSManagedObjectModel *) MR_newManagedObjectModelNamed:(NSString *)modelFileName
{
	NSString *path = [[NSBundle mainBundle] pathForResource:[modelFileName stringByDeletingPathExtension] 
                                                     ofType:[modelFileName pathExtension]];
    
    if (specifiedBundle_)
    {
        path = [specifiedBundle_ pathForResource:[modelFileName stringByDeletingPathExtension]
                                           ofType:[modelFileName pathExtension]];
    }
    
	NSURL *momURL = [NSURL fileURLWithPath:path];
	
	NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
	return model;
}

+ (NSManagedObjectModel *) MR_managedObjectModelNamed:(NSString *)modelFileName
{
    NSManagedObjectModel *model = [self MR_newManagedObjectModelNamed:modelFileName];
	return model;
}

+ (void)setSpecifidBundle:(NSBundle *)specifiedBundle
{
    specifiedBundle_ = specifiedBundle;
    
    // reset defaultManagedObjectModel_
    [self MR_setDefaultManagedObjectModel:[self MR_mergedObjectModelFromMainBundle]];
}

@end
