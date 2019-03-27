//
//  AutoMD5Model.m
//  Demo
//
//  Created by 郭晓倩 on 2019/3/27.
//  Copyright © 2019年 郭晓倩. All rights reserved.
//

#import "AutoMD5Model.h"
#include <objc/runtime.h>
#import <CommonCrypto/CommonCrypto.h>

/// String's md5 hash.
static NSString *NSStringMD5(NSString *string) {
    if (!string) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@interface AutoMD5Model ()
{
    NSString* _propertyMD5;
}

@end

@implementation AutoMD5Model

- (NSString*)allPropertMD5;
{
    NSMutableString* description = [NSMutableString string];
    Class cls = [self class];
    while (cls != [NSObject class]) {
        unsigned int numberOfProperty = 0;
        objc_property_t* propertList = class_copyPropertyList(cls, &numberOfProperty);
        for(const objc_property_t* p = propertList;p<propertList+numberOfProperty;p++){
            objc_property_t const property = *p;
            const char* type = property_getName(property);
            NSString* key = [NSString stringWithUTF8String:type];
            id value = [self valueForKey:key];
            if(value&&([self propertyExcept:key])){
                NSString* dValue = [value description];
                [description appendString:dValue?dValue:@""];
            }
            
        }
        if(propertList){
            free(propertList);
            propertList = nil;
        }
        cls = class_getSuperclass(cls);
    }
    
    return NSStringMD5(description);
}

- (BOOL)propertyExcept:(NSString*)value
{
    return YES;
}

- (BOOL)needUp
{
    
    NSString* md5 = [self allPropertMD5];
    if(!_propertyMD5 && md5){
        _propertyMD5 = [NSString stringWithString:md5];
        return YES;
    }
    if(!md5 || !_propertyMD5)return YES;
    BOOL flag =  [_propertyMD5 isEqualToString:md5];
    _propertyMD5 = [NSString stringWithString:md5];
    return flag;
}


@end
