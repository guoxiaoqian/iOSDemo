//
//  CppTestVC.m
//  Demo
//
//  Created by gavinxqguo on 2020/9/7.
//  Copyright © 2020 郭晓倩. All rights reserved.
//

#import "CppTestVC.h"
#include <sstream>
#include <string>

using namespace std;

@implementation CppTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self testString];
    
    [self testSharedPtr];
}

- (void)testString {
    unsigned char xml_flag = 0;
    string xml_template = "<?xml version=\"1.0\" encoding=\"utf-8\"?><msg brief=\"[聊天记录]\" m_fileName=\"C5930D79-4935-4908-8516-FC1456499257\" action=\"viewMultiMsg\" flag=\"3\" m_resid=\"xELjliQpjr8Z7/Zaodv1I9m3TpsE67hX6mp8pYmAdnCjejON00VcVbzAOFp3LGT0\" serviceID=\"35\" m_fileSize=\"180\"><item layout=\"1\"><title color=\"#000000\" size=\"34\">郭晓倩/[u]a[/u]和雨过天晴 ㄟ的聊天记录</title><title color=\"#777777\" size=\"26\">雨过天晴 ㄟ: 你啊哈</title><title color=\"#777777\" size=\"26\">郭晓倩/[u]a[/u]: Dads</title><hr></hr><summary color=\"#808080\" size=\"26\">查看2条转发消息</summary></item><source name=\"聊天记录\"></source></msg>";
    ostringstream oss;
    oss << xml_flag << xml_template;
    string result = oss.str();
    const char* ss = "fengjuntao";
    const char* s = 1+ss;
    NSString* str1 = [NSString stringWithUTF8String:1+result.c_str()];
    NSString* str2 = [NSString stringWithUTF8String:xml_template.c_str()];
    
    NSLog(@"testString: str1=%@ str2=%@",str1,str2);
}

- (void)testSharedPtr {
    std::shared_ptr<std::string> sp2= nullptr;
    std::shared_ptr<std::string> sp = std::make_shared<std::string>("hello world");
    NSLog(@"testSharedPtr: size=%ld",sizeof(sp));
    NSLog(@"testSharedPtr: use_count1=%ld",sp.use_count());
    sp2= std::shared_ptr<std::string>(sp.get());
    NSLog(@"testSharedPtr: use_count1=%ld use_count2=%ld ",sp.use_count(),sp2.use_count());
}

@end
