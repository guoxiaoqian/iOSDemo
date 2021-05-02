//
//  CrashVC.m
//  Demo
//
//  Created by gavinxqguo on 2019/7/26.
//  Copyright © 2019 郭晓倩. All rights reserved.
//

#import "CrashVC.h"
#import <WebKit/WebKit.h>

#include <string>
using namespace std;




@interface CrashVCKVOObj : NSObject
@property (nonatomic, strong) NSString *name;
@end
@implementation CrashVCKVOObj

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context {
    NSLog(@"keyPath = %@", keyPath);
}
@end



@interface CrashVCNotificationObj : NSObject

@end
@implementation CrashVCNotificationObj

- (void)handleNotification:(NSNotification*)noti {
    NSLog(@"receive notification");
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


@interface CrashVC ()

@property (strong,nonatomic) NSString* url;

@property (nonatomic, strong) CrashVCKVOObj *sObj;

@property (strong,nonatomic) WKWebView* wkWebView;


@end

@implementation CrashVC

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self testCrash_ObjcRetain];

//    [self testCrash_String];
    
//    [self testCrash_MutableString];
    
//    [self testCrash_CollectionRemove];
    
//    [self testCrash_KVO];
    
//    [self testCrash_Timer];
//
//    [self testCrash_Notification];
    
//    [self testCrash_WKWebview];
    
//    [self testCrash_WildPointer];
    
    [self testCrash_CPPStringWithNULL];
}

#pragma mark - 多线程

- (void)testCrash_ObjcRetain{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self modifyUrl];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self readUrl];
    });
}

- (void)modifyUrl {
    while (1) {
        _url = [[NSString alloc] initWithFormat:@"123456789%d",1];
    }
}

- (void)readUrl {
    while (1) {
        [self openUrl:self.url];
    }
}

- (void)openUrl:(id)url {
}

#pragma mark - 集合

- (void)testCrash_String {
    NSString* str = nil;
    NSLog(@"%s",[str UTF8String]);
    cppString([str UTF8String]);
}

void cppString(const string& value) {
    
}

- (void)testCrash_MutableString {
    NSString* str = nil;
    NSString* mstr = [[NSMutableString alloc] initWithString:str];
    NSLog(@"%@",mstr);
}

#pragma mark - 集合

- (void)testCrash_CollectionRemove {
    NSMutableArray* array = [[NSMutableArray alloc] initWithObjects:@(1),@(2),@(3),@(4),@(5),nil];
    // 不崩溃
    [array enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.integerValue == 1) {
            [array removeObject:obj];
        }
    }];
    // 崩溃，reason: '*** Collectionwas mutated while being enumerated.'
    for (NSNumber* obj in array) {
        if (obj.integerValue == 2) {
            [array removeObject:obj];
        }
    }
}

#pragma mark - KVO

- (void)testCrash_KVO {
    
    self.sObj = [[CrashVCKVOObj alloc] init];

//    [self func1];
    
//    [self func3];
    
//    [self func4];
    
    [self func5];
}
/**
 观察者是否后，收到通知，会崩溃
 */
- (void)func1 {
    // 崩溃日志：An -observeValueForKeyPath:ofObject:change:context: message was received but not handled.
    CrashVCKVOObj* obj = [[CrashVCKVOObj alloc] init];
    [self addObserver:obj           forKeyPath:@"view"  options:NSKeyValueObservingOptionNew
              context:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.view = [[UIView alloc] init];
    });
}

/**
 没有实现observeValueForKeyPath:ofObject:changecontext:方法:，会崩溃
 */
- (void)func3 {
    // 崩溃日志：An -observeValueForKeyPath:ofObject:change:context: message was received but not handled.
    [self.sObj addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    self.sObj.name = @"0";
}
/**
 重复移除观察者，会崩溃
 */
- (void)func4 {
    // 崩溃日志：because it is not registered as an observer
    [self.sObj addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    self.sObj.name = @"0";
    [self.sObj removeObserver:self forKeyPath:@"name"];
    [self.sObj removeObserver:self forKeyPath:@"name"];
}
/**
 重复添加观察者，不会崩溃，但是添加多少次，一次改变就会被观察多少次
 */
- (void)func5 {
    [self.sObj addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    [self.sObj addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    self.sObj.name = @"0";
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context {
    NSLog(@"keyPath = %@", keyPath);
}

#pragma mark - Timer

- (void)testCrash_Timer {
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)onTimer:(NSTimer*)timer {
    NSLog(@"timer = %@",timer);
    [timer invalidate];
}

#pragma mark - Notification

- (void)testCrash_Notification {
    CrashVCNotificationObj* obj = [CrashVCNotificationObj new];
    NSString* notiName = @"CrashVCNotificationObj";
    [[NSNotificationCenter defaultCenter] addObserver:obj selector:@selector(handleNotification:) name:notiName object:nil];
    
    //iOS9后不会崩溃
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notiName object:nil];
    });
}

#pragma mark - WKWebview

- (void)testCrash_WKWebview {
    self.wkWebView =  [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 300)];
    [self.view addSubview:self.wkWebView];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    [self.wkWebView loadRequest:request];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.wkWebView evaluateJavaScript:@"alert()" completionHandler:^(id _Nullable, NSError * _Nullable error) {
            NSLog(@"wkwebview error = %@",error);
        }];
    });
}


#pragma mark - WKWebview

- (void)testCrash_WildPointer{
    
    __unsafe_unretained NSObject* obj = nil;
    {
        NSObject* tmpObj = [NSObject new];
        obj = tmpObj;
    }
    NSLog(@"dealloced obj = %@",obj.description);
}

#pragma mark - String

- (void)testCrash_CPPStringWithNULL {
    
    string s(nil);
    NSLog(@"cpp string = %s",s.c_str());
}

@end
