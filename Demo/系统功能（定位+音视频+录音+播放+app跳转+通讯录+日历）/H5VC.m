//
//  H5VC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/4/25.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "H5VC.h"
#import <WebKit/WebKit.h>

@interface H5VC () <UIWebViewDelegate>

@property (strong,nonatomic) UIWebView* uiWebView;
@property (strong,nonatomic) WKWebView* wkWebView;

@end

@implementation H5VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//UIWebView与WKWebView比较
//UIWebView:IOS2引入，内存占用很大，加载速度慢，优化困难
//WKWebView:IOS8引入，替换UIWebView，特点：
//1.在性能、稳定性、功能方面有很大提升（最直观的体现就是加载网页是占用的内存，模拟器加载百度与开源中国网站时，WKWebView占用23M，而UIWebView占用85M）；
//2.允许JavaScript的Nitro库加载并使用（UIWebView中限制）；
//3.支持了更多的HTML5特性；
//4.高达60fps的滚动刷新率以及内置手势；
//5.将UIWebViewDelegate与UIWebView重构成了14类与3个协议

#pragma mark - UIWebView

-(void)showUIWebView{
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
    webView.delegate = self;
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    [webView loadRequest:request];
    
    [self.view addSubview:webView];
    
    self.uiWebView = webView;
}

-(void)otherUIWebViewFunction{
    //    加载函数。
    //    - (void)loadRequest:(NSURLRequest *)request;
    //    - (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;
    //    - (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;
    //    UIWebView不仅可以加载HTML页面，还支持pdf、word、txt、各种图片等等的显示。
    //    // 1.获取url
    //    NSURL *url = [NSURL fileURLWithPath:@"/Users/coohua/Desktop/bigIcon.png"];
    //    // 2.创建请求
    //    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    //    // 3.加载请求
    //    [self.webView loadRequest:request];
    
    
    //    网页导航刷新有关函数
    //    // 刷新
    //    - (void)reload;
    //    // 停止加载
    //    - (void)stopLoading;
    //    // 后退函数
    //    - (void)goBack;
    //    // 前进函数
    //    - (void)goForward;
    //    // 是否可以后退
    //    @property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
    //    // 是否可以向前
    //    @property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;
    //    // 是否正在加载
    //    @property (nonatomic, readonly, getter=isLoading) BOOL loading;
}

-(void)UIWebViewWithJS{
    //js执行OC代码：js是不能执行oc代码的，但是可以变相的执行，js可以将要执行的操作封装到网络请求里面，然后oc拦截这个请求，获取url里面的字符串解析即可，这里用到代理协议的- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType函数。
    
    
    //oc调取写好的js代码:
    // 实现自动定位js代码, htmlLocationID为定位的位置(由js开发人员给出)，实现自动定位代码，应该在网页加载完成之后再调用
    NSString* htmlLocationID = @"";
    NSString *javascriptStr = [NSString stringWithFormat:@"window.location.href = '#%@'",htmlLocationID];
    [self.uiWebView stringByEvaluatingJavaScriptFromString:javascriptStr];
    // 获取网页的title
    NSString *title = [self.uiWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

#pragma mark UIWebViewDelegate

/// 是否允许加载网页，也可获取js要打开的url，通过截取此url可与js交互
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    LOG_FUNCTION;
    
    NSString *urlString = [[request URL] absoluteString];
    urlString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"shouldStartLoadWithRequest-url:%@",urlString);
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    LOG_FUNCTION;
    NSURLRequest *request = webView.request;
    NSLog(@"webViewDidStartLoad-url=%@--%@",[request URL],[request HTTPBody]);
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    LOG_FUNCTION;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    LOG_FUNCTION;
}

#pragma mark - WKWebView

-(void)showWKWebView{
    WKWebView* webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 200+5, kScreenWidth, 200) configuration:nil];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    [webView loadRequest:request];
    
    [self.view addSubview:webView];
    
    self.wkWebView = webView;
}

-(void)otherWKWebViewFunction{
    /// 其它三个加载函数
    //    - (WKNavigation *)loadRequest:(NSURLRequest *)request;
    //    - (WKNavigation *)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;
    //    - (WKNavigation *)loadData:(NSData *)data MIMEType:(NSString *)MIMEType characterEncodingName:(NSString *)characterEncodingName baseURL:(NSURL *)baseURL;
    
    
    //网页导航刷新相关函数
    //    和UIWebview几乎一样，不同的是有返回值，WKNavigation(已更新)
    //    @property (nonatomic, readonly) BOOL canGoBack;
    //    @property (nonatomic, readonly) BOOL canGoForward;
    //    - (WKNavigation *)goBack;
    //    - (WKNavigation *)goForward;
    //    - (WKNavigation *)reload;
    //    - (WKNavigation *)reloadFromOrigin; // 增加的函数,会比较网络数据是否有变化，没有变化则使用缓存，否则从新请求。
    //    - (WKNavigation *)goToBackForwardListItem:(WKBackForwardListItem *)item; // 增加的函数,比向前向后更强大，可以跳转到某个指定历史页面
    //    - (void)stopLoading;
    
    
    //一些常用属性
    //    allowsBackForwardNavigationGestures：BOOL类型，是否允许左右划手势导航，默认不允许
    //    estimatedProgress：加载进度，取值范围0~1
    //    title：页面title
    //    .scrollView.scrollEnabled：是否允许上下滚动，默认允许
    //    backForwardList：WKBackForwardList类型，访问历史列表，可以通过前进后退按钮访问，或者通过goToBackForwardListItem函数跳到指定页面
    
}


@end
