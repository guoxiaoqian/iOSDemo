//
//  MakeFuzzyVC.m
//  Demo
//
//  Created by gavinxqguo on 2020/4/3.
//  Copyright © 2020 郭晓倩. All rights reserved.
//

#import "MakeFuzzyVC.h"

@interface MakeFuzzyVC ()

@property (strong,nonatomic)  NSDictionary* dicReg;

@end

@implementation MakeFuzzyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self desensitizationHandle:@"手机 86-18918278174"];
    [self desensitizationHandle:@"手机18918278174"];
    [self desensitizationHandle:@"Qq 4292667703"];
    [self desensitizationHandle:@"邮箱 4292667703@qq.com"];
    [self desensitizationHandle:@"身份证 370283199012131515"];
    [self desensitizationHandle:@"电话  0532-3368028"];
    
//    NSString* tokenStr = @"<9a4cc2b0 59165780 b93d62aa e6022556 db428fa4 5c66e280 e21bb254 43851c56>";
//     int data[8] = {1,2,3,4,5,6,7,8};
//
//     NSData* deviceToken = [[NSData alloc] initWithBytes:data length:32];
//
//     const unsigned *tokenBytes = (const unsigned *)[deviceToken bytes];
//     NSString *strToken = [NSString stringWithFormat:@"<%08x %08x %08x %08x %08x %08x %08x %08x>",
//                           ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
//                           ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
//                           ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
//     NSLog(@"deviceToken1:%@", strToken);
//
//    char* chars = [deviceToken bytes];
//    NSMutableString* hexString = [[NSMutableString alloc] init];
//    for (NSUInteger i=0; i < deviceToken.length;i++) {
//        hexString appendString:[NSString stringWithFormat:@"%0.2hhx",chars[i]];
//    }

}

//脱敏处理
- (NSString *)desensitizationHandle:(NSString *)inputText
{
    if (inputText.length == 0) {
        return nil;
    }
    
    //脱敏正则
    NSDictionary* dicReg =@{@"(电话|手机|联系方式){1}.{0,5}?(1\\d{10})":@(2),
                            @"([1-9]\\d{5}[12]\\d{3}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])\\d{3}[0-9xX])":@(1),
                            @"[Qq]{2}.{0,5}?(\\d{5,11})":@(1),
                             @"(电话|手机|联系方式){1}.{0,5}?((\\d{3,4})[- ]\\d{7,8})":@(2),
                             @"(电话|手机|联系方式){1}.{0,5}?(\\d{3,4}[- ]\\d{7,8})":@(2),
                             @"(邮箱|email){1}.{0,5}?([a-zA-Z0-9]{3,}@[a-zA-Z0-9\\.]{5,})":@(2),
                             @"(卡号|银行帐号){1}.{0,5}?([0-9]{16,19})":@(2),
                             @"(卡号|银行帐号){1}.{0,5}?([0-9]{4} [0-9]{4} [0-9]{4} [0-9]{4} [0-9]{3})":@(2),
                             @"(微信){1}.{0,5}?([a-zA-Z0-9]{5,11})":@(2),
                             @"(护照){1}.{0,5}?(([GPSD]|[0-9]){7,10})":@(2)};
    self.dicReg = dicReg;
    NSArray* arrReg = dicReg.allKeys;
    
    
//    NSArray* arrReg = @[@"[电话|手机|联系方式]{1}.{0,5}?(1\\d{10})",
//                        @"([1-9]\\d{5}[12]\\d{3}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])\\d{3}[0-9xX])",
//                        @"[qq|QQ]{1}.{0,5}?(\\d{5,11})",
//                        @"[电话|手机|联系方式]{1}.{0,5}?((\\d{3,4})[- ]\\d{7,8})",
//                        @"[电话|手机|联系方式]{1}.{0,5}?(\\d{3,4}[- ]\\d{7,8})",
//                        @"[邮箱|email]{1}.{0,5}?([a-zA-Z0-9]{3,}@[a-zA-Z0-9\\.]{5,})",
//                        @"[卡号|银行帐号]{1}.{0,5}?([0-9]{16,19})",
//                        @"[卡号|银行帐号]{1}.{0,5}?([0-9]{4} [0-9]{4} [0-9]{4} [0-9]{4} [0-9]{3})",
//                        @"[微信|WX]{1}.{0,5}?([a-zA-Z0-9]{5,11})",
//                        @"[护照]{1}.{0,5}?(([GPSD]|[0-9]){7,10})"];
    
    NSString *strOutput = [inputText copy];
    for (NSString *strReg in arrReg) {
        //获取字符串中的敏感字符串集合
        NSArray *arrMatchString = [self matchTheRegexSource:inputText andPattern:strReg];
        if (arrMatchString) {
            for (NSString *strMatch in arrMatchString) {
                //获取模糊字符后直接替换掉敏感字符
                NSString *strFuzzy = [self getFuzzyString:strMatch];
                if (strFuzzy) {
                    strOutput = [strOutput stringByReplacingOccurrencesOfString:strMatch withString:strFuzzy];
                }
            }
        }
    }
    
    NSLog(@"origin:%@ fuzzy:%@",inputText,strOutput);
    
    return strOutput;
}

- (NSArray *)matchTheRegexSource:(NSString *)source
                      andPattern:(NSString *)pattern
{
    if (!source || !pattern) {
        return nil;
    }
    
    NSError *err = nil;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern
                                                    options:NSRegularExpressionCaseInsensitive
                                                      error:&err];

    if (err) {
        return nil;
    }
    
    __block NSMutableArray *mArrResults = nil;
    __block NSString *matchString = nil;
    
    int resultRangeIndex = [self.dicReg[pattern] intValue];
    
    [reg enumerateMatchesInString:source
                          options:NSMatchingReportCompletion
                            range:NSMakeRange(0, source.length)
                       usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {

                           if (result) {
                               NSRange range;
                               if (result.numberOfRanges > resultRangeIndex) {
//                                   range = [result rangeAtIndex:result.numberOfRanges-1];
                                   range = [result rangeAtIndex:resultRangeIndex];
                               }
                               else {
                                   range = result.range;
                               }
                               if (!mArrResults) {
                                   mArrResults = [NSMutableArray array];
                               }
                               matchString = [source substringWithRange:range];
                               [mArrResults addObject:matchString];
                           }
                       }];
    
    return mArrResults;
}

//获取脱敏后的字符串
- (NSString *)getFuzzyString:(NSString *)inputText
{
    if (inputText.length == 0) {
        return nil;
    }
    
    NSMutableString *mStrOutput = [NSMutableString stringWithString:inputText];
    if (mStrOutput.length > 6) {
        NSString *paddingStar = [@"" stringByPaddingToLength:mStrOutput.length - 6 withString:@"*" startingAtIndex:0];
        [mStrOutput replaceCharactersInRange:NSMakeRange(3, mStrOutput.length - 6) withString:paddingStar];
    } else if (mStrOutput.length > 1) {
        NSString *paddingStar = [@"" stringByPaddingToLength:mStrOutput.length - 2 withString:@"*" startingAtIndex:0];
        [mStrOutput replaceCharactersInRange:NSMakeRange(1, mStrOutput.length - 2) withString:paddingStar];
    } else {
        return @"*";
    }
    return mStrOutput;
}

@end
