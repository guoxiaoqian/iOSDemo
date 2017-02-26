//
//  NetworkVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/2/25.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "NetworkVC.h"

#define Kboundary @"----WebKitFormBoundaryjv0UfA04ED44AhWx"


@interface NetworkVC ()<NSURLSessionDownloadDelegate>

@property (strong,nonatomic) NSData* resumeDownloadData;

@end

@implementation NetworkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self sessionGeneralRequest];
    
//    [self sessionDownload];
    
    [self sessionUpload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - URLSession

-(NSURL*)url{
    return [NSURL URLWithString:@"https://www.baidu.com"];
}

-(NSURLSession*)session{
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    return [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
}

-(void)sessionGeneralRequest{
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:[self url]];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.timeoutInterval = 10;
    urlRequest.allowsCellularAccess = YES;
    urlRequest.HTTPBody = [@"guoxiaoqian" dataUsingEncoding:NSUTF8StringEncoding];
    urlRequest.HTTPShouldHandleCookies = YES;
    [urlRequest setValue:@"text/plain,text/html" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"utf-8" forHTTPHeaderField:@"Accept-Charset"];

    NSURLSessionTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString* responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%s responseBody = %@",__FUNCTION__,responseBody);
        NSLog(@"%s responseMIMEType = %@ charset = %@",__FUNCTION__,response.MIMEType,response.textEncodingName);
    }];
    [task resume];
}

//简单下载
-(NSURLSessionDownloadTask*)sessionDownload{
    NSURLSessionDownloadTask* task = [[self session] downloadTaskWithURL:[self url] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString* targetURL = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL URLWithString:targetURL] error:nil];
    }];
    [task resume];
    return task;
}

//断点下载
-(void)sessionResumeDownload{
    NSURLSessionDownloadTask* task = [self sessionDownload];
    [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        self.resumeDownloadData = resumeData;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSURLSessionDownloadTask* resumeTask = [[self session] downloadTaskWithResumeData:self.resumeDownloadData];
        [resumeTask resume];
    });
}

//上传文件
-(void)sessionUpload{
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:[self url]];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.timeoutInterval = 10;
    urlRequest.cachePolicy = NSURLRequestReturnCacheDataElseLoad;

    [urlRequest setValue:[NSString stringWithFormat:@"multipart/form-data;charsert=utf-8;boundary=%@",Kboundary] forHTTPHeaderField:@"Content-Type"];

    NSString* fileName = @"file.png";
    NSData* bodyData = [self createUploadBodyWithFileName:fileName fileData:UIImagePNGRepresentation([UIImage imageNamed:fileName])];

    NSURLSessionUploadTask* task = [[self session] uploadTaskWithRequest:urlRequest fromData:bodyData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
    [task resume];
}

-(NSData*)createUploadBodyWithFileName:(NSString*)fileName fileData:(NSData*)fileData{
    //    HTTP请求体：
    //    --AaB03x （边界到下一行用了换行，在oc里面 用 \r\n 来定义换一行 所以下面不要奇怪它的用法）
    //    Content-Disposition: form-data; name="key1"（这行到 value1 换了2行，所以，自然而然 \r\n\r\n ）
    //
    //    value1
    //    --AaB03x
    //    Content-disposition: form-data; name="key2"; filename="file"
    //    Content-Type: application/octet-stream
    //
    //    图片数据...//NSData
    //    --AaB03x--（结束的分割线也不要落下）
    NSMutableString* bodyStr = [NSMutableString new];
    [bodyStr appendFormat:@"%@\r\n",Kboundary];
    [bodyStr appendFormat:@"Content-disposition:form-data;name=\"file\";filename=\"%@\"\r\n",fileName];
    [bodyStr appendFormat:@"Content-Type:application/octet-stream\r\n\r\n"];

    NSMutableData* bodyData = [NSMutableData new];
    [bodyData appendData:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:fileData];
    return fileData;
}

#pragma mark NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    NSLog(@"%s\n  download:%lld total:%lld",__FUNCTION__,totalBytesWritten,totalBytesExpectedToWrite);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    NSLog(@"%s\n  offset:%lld total:%lld",__FUNCTION__,fileOffset,expectedTotalBytes);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@"%s",__FUNCTION__);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    NSLog(@"%s\n  upload:%lld total:%lld",__FUNCTION__,totalBytesSent,totalBytesExpectedToSend);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"%s",__FUNCTION__);
    if (error) {
        self.resumeDownloadData = [[error userInfo] objectForKey:NSURLSessionDownloadTaskResumeData];
    }
}

@end
