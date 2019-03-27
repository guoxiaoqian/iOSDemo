//
//  AutoCodingModel.m
//  Demo
//
//  Created by 郭晓倩 on 2019/3/27.
//  Copyright © 2019年 郭晓倩. All rights reserved.
//

#import "AutoCodingModel.h"
#include <objc/runtime.h>

@implementation AutoCodingModel

- (void)encodeWithCoder:(NSCoder *)encoder {
    Class cls = [self class];
    while (cls != [NSObject class]) {
        unsigned int numberOfIvars = 0;
        Ivar* ivars = class_copyIvarList(cls, &numberOfIvars);
        for(const Ivar* p = ivars; p < ivars+numberOfIvars; p++)
        {
            Ivar const ivar = *p;
            const char *type = ivar_getTypeEncoding(ivar);
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            if (key == nil){
                continue;
            }
            if ([key length] == 0){
                continue;
            }
            
            id value = [self valueForKey:key];
            if (value) {
                switch (type[0]) {
                    case _C_STRUCT_B: {
                        NSUInteger ivarSize = 0;
                        NSUInteger ivarAlignment = 0;
                        NSGetSizeAndAlignment(type, &ivarSize, &ivarAlignment);
                        NSData *data = [NSData dataWithBytes: (__bridge void*)self + ivar_getOffset(ivar)
                                                      length:ivarSize];
                        [encoder encodeObject:data forKey:key];
                    }
                        break;
                    default:
                        [encoder encodeObject:value
                                       forKey:key];
                        break;
                }
            }
        }
        if (ivars) {
            free(ivars);
        }
        
        cls = class_getSuperclass(cls);
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    
    if (self) {
        Class cls = [self class];
        while (cls != [NSObject class]) {
            unsigned int numberOfIvars = 0;
            Ivar* ivars = class_copyIvarList(cls, &numberOfIvars);
            
            for(const Ivar* p = ivars; p < ivars+numberOfIvars; p++)
            {
                Ivar const ivar = *p;
                const char *type = ivar_getTypeEncoding(ivar);
                NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
                if (key == nil){
                    continue;
                }
                if ([key length] == 0){
                    continue;
                }
                id value = [decoder decodeObjectForKey:key];
                if (value) {
                    switch (type[0]) {
                        case _C_STRUCT_B: {
                            NSUInteger ivarSize = 0;
                            NSUInteger ivarAlignment = 0;
                            NSGetSizeAndAlignment(type, &ivarSize, &ivarAlignment);
                            NSData *data = [decoder decodeObjectForKey:key];
                            char *sourceIvarLocation = (__bridge void*)self+ ivar_getOffset(ivar);
                            [data getBytes:sourceIvarLocation length:ivarSize];
                            memcpy((__bridge void*)self + ivar_getOffset(ivar), sourceIvarLocation, ivarSize);
                        }
                            break;
                        default:
                            [self setValue:value forKey:key];
                            break;
                    }
                }
            }
            
            if (ivars) {
                free(ivars);
            }
            cls = class_getSuperclass(cls);
        }
    }
    
    return self;
}

@end

