//
//  NetworkVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/2/25.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "NetworkVC.h"
#import "AFNetworking.h"

#define Kboundary @"----WebKitFormBoundaryjv0UfA04ED44AhWx"


@interface NetworkVC ()<NSURLSessionDownloadDelegate,NSURLConnectionDataDelegate>

@property (strong,nonatomic) NSData* resumeDownloadData;

@end

@implementation NetworkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    [self urlConnnection];
//    
//    [self sessionGeneralRequest];
    
    [self sessionDownload];
    
//    [self sessionUpload];
//
//    [self afNetworkGeneralRequest];
//    
//    [self afNetworkingMultiPartFormRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    LOG_FUNCTION;
}

#pragma mark - URLConnection

-(void)urlConnnection{
    
    NSURLRequest* request = [self generalRequest];
    NSURLResponse *response = nil;
    NSError* error = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"NSURLConnection sync response:%@ error:%@",response,error);
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSLog(@"NSURLConnection async response:%@ error:%@",response,error);
    }];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"NSURLConnection delgate response:%@",response);
}

#pragma mark - URLSession

-(NSURL*)url{
    return [NSURL URLWithString:@"https://www.baidu.com"];
}

-(NSMutableURLRequest*)generalRequest{
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:[self url]];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.timeoutInterval = 10;
    urlRequest.allowsCellularAccess = YES;
    urlRequest.HTTPBody = [@"guoxiaoqian" dataUsingEncoding:NSUTF8StringEncoding];
    urlRequest.HTTPShouldHandleCookies = YES;
    [urlRequest setValue:@"text/plain,text/html" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"utf-8" forHTTPHeaderField:@"Accept-Charset"];

    return urlRequest;
}

-(NSURLSession*)session{
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    return [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
}

-(void)sessionGeneralRequest{
    
    NSURLSessionTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:[self generalRequest] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString* responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%s responseBody = %@",__FUNCTION__,responseBody);
        NSLog(@"%s responseMIMEType = %@ charset = %@",__FUNCTION__,response.MIMEType,response.textEncodingName);
    }];
    [task resume];
}

//简单下载
-(NSURLSessionDownloadTask*)sessionDownload{
    __block NSURLSession* sesssion = [self session];
    NSURLSessionDownloadTask* task = [sesssion downloadTaskWithURL:[self url] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString* targetURL = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL URLWithString:targetURL] error:nil];
        
        //使用了Block，Delegate就不会回调
        
        //因为session强持有delegate，必须Invidate才能释放
        [sesssion finishTasksAndInvalidate];
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
    
    //构建报文体
    NSString* fileName = @"file.png";
    NSData* bodyData = [self createUploadBodyWithFileName:fileName fileData:UIImagePNGRepresentation([UIImage imageNamed:fileName])];
    
    //构建HTTP请求
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:[self url]];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.timeoutInterval = 60;
    urlRequest.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    [urlRequest setValue:[NSString stringWithFormat:@"multipart/form-data;charset=utf-8;boundary=%@",Kboundary] forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%tu", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
    
    
    NSURLSessionUploadTask* task = [[self session] uploadTaskWithRequest:urlRequest fromData:bodyData];
    [task resume];
}

-(NSData*)createUploadBodyWithFileName:(NSString*)fileName fileData:(NSData*)fileData{
    //    HTTP请求体：
    //    --boundary （边界到下一行用了换行，在oc里面 用 \r\n 来定义换一行 所以下面不要奇怪它的用法）
    //    Content-Disposition: form-data; name="key1"（这行到 value1 换了2行，所以，自然而然 \r\n\r\n ）
    //
    //    value1
    //    --boundary
    //    Content-disposition: form-data; name="key2"; filename="file"
    //    Content-Type: application/octet-stream
    //
    //    图片数据...//NSData
    //    --boundary--（结束的分割线也不要落下）
    NSMutableString* bodyStr = [NSMutableString new];
    [bodyStr appendFormat:@"--%@\r\n",Kboundary];
    [bodyStr appendFormat:@"Content-disposition:form-data;name=\"file\";filename=\"%@\"\r\n",fileName];
    [bodyStr appendFormat:@"Content-Type:application/octet-stream\r\n\r\n"];
    
    NSMutableData* bodyData = [NSMutableData new];
    [bodyData appendData:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:fileData];
    [bodyData appendData:[[NSString stringWithFormat:@"--%@--",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
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
    
    [session finishTasksAndInvalidate];
}

#pragma mark - AFNetworking

- (void)afNetworkGeneralRequest{
    [[AFHTTPSessionManager manager] GET:[[self url] absoluteString]
                             parameters:nil
                                success:^(NSURLSessionDataTask *task, id responseObject) {
                                    NSLog(@"%s responseObject = %@",__FUNCTION__,responseObject);
                                }
                                failure:^(NSURLSessionDataTask *task, NSError *error) {
                                    
                                }];
}

- (void)afNetworkingMultiPartFormRequest{
    NSString* fileName = @"file.png";
    NSURL* fileURL = [[NSBundle mainBundle] URLForResource:@"file" withExtension:@"png"];
    [[AFHTTPSessionManager manager] POST:[[self url] absoluteString]
                              parameters:nil
               constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                   [formData appendPartWithFileURL:fileURL name:fileName error:nil];
               }
                                 success:^(NSURLSessionDataTask *task, id responseObject) {
                                     NSLog(@"%s responseObject = %@",__FUNCTION__,responseObject);
                                 }
                                 failure:^(NSURLSessionDataTask *task, NSError *error) {
                                     
                                 }];
}

@end
