//
//  H5VC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/4/25.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "H5VC.h"
#import <WebKit/WebKit.h>

#import "SystemInfoVC.h"

#import <JavaScriptCore/JavaScriptCore.h>

#define TEST_LOAD_URL 1
#define TEST_ITEM_HEGITH 100
#define TEST_ITEM_NUM 10

@interface H5VC () <UIWebViewDelegate,WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property (strong,nonatomic) UIWebView* uiWebView;
@property (strong,nonatomic) WKWebView* wkWebView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic) JSContext* jsContext;

@end

@implementation H5VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //
    //    [self showUIWebView];
    //
    //    [self UIWebViewWithJS];
    //
    //    [self showWKWebView];
    //
    //    [self WKWebViewWithJS];
    
//    [self testWKWebView];
    
    [self testJSCoreDemo];
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
    
    [self.scrollView addSubview:webView];
    
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
    WKWebView* webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 200+5, kScreenWidth, 200)];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    [webView loadRequest:request];
    
    [self.scrollView addSubview:webView];
    
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

-(void)WKWebViewWithJS{
    //1、动态加载并运行JS代码
    
    // 图片缩放的js代码
    NSString *js = @"window.alert('呵呵');";
    // 根据JS字符串初始化WKUserScript对象
    WKUserScript *script = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    // 根据生成的WKUserScript对象，初始化WKWebViewConfiguration
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config.userContentController addUserScript:script];
    
    WKWebView* webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 400+2, kScreenWidth, 200) configuration:config];
    webview.UIDelegate = self;
    webview.navigationDelegate = self;
    
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    [self.scrollView addSubview:webview];
    
    //2.webView 执行JS代码
    
    //javaScriptString是JS方法名，completionHandler是异步回调block
    [webview evaluateJavaScript:@"window.alert('郭晓倩');" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
    
    //3.JS调用App注册过的方法
    
    //OC注册供JS调用的方法;NOTE:强持有self,会造成循环引用，使用Protocol代理解决
    [[webview configuration].userContentController addScriptMessageHandler:self name:@"closeMe"];
    
    //OC在JS调用方法做的处理
    //    - (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    //        NSLog(@"JS 调用了 %@ 方法，传回参数 %@",message.name,message.body);
    //    }
    
    //JS调用
    //    window.webkit.messageHandlers.closeMe.postMessage(null);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [webview evaluateJavaScript:@"window.webkit.messageHandlers.closeMe.postMessage('牛兆娟');" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            
        }];
    });
}

#pragma mark - WKNavigationDelegate 最常用，和UIWebViewDelegate功能类似，追踪加载过程，有是否允许加载、开始加载、加载完成、加载失败。下面会对函数做简单的说明，并用数字标出调用的先后次序：1-2-3-4-5

//三个是否允许加载函数：

/// 接收到服务器跳转请求之后调用 (服务器端redirect)，不一定调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    LOG_FUNCTION;
}
/// 3 在收到服务器的响应头，根据response相关信息，决定是否跳转。decisionHandler必须调用，来决定是否跳转，参数WKNavigationActionPolicyCancel取消跳转，WKNavigationActionPolicyAllow允许跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    LOG_FUNCTION;
    decisionHandler(WKNavigationResponsePolicyAllow);
}
/// 1 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    LOG_FUNCTION;
    
    // 拦截scheme方式跳转
    if([[UIApplication sharedApplication] openURL:navigationAction.request.URL])
    {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else
    {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
//    decisionHandler(WKNavigationActionPolicyAllow);
}

//追踪加载过程函数:

/// 2 页面开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    LOG_FUNCTION;
}
/// 4 开始获取到网页内容时返回
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    LOG_FUNCTION;
}
/// 5 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    LOG_FUNCTION;
}
/// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    LOG_FUNCTION;
}

#pragma mark - WKScriptMessageHandler：必须实现的函数，是APP与js交互，提供从网页中收消息的回调方法

/// message: 收到的脚本信息.
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    LOG_FUNCTION;
    NSLog(@"JS 调用了 %@ 方法，传回参数 %@",message.name,message.body);
    
}

#pragma mark - WKUIDelegate：UI界面相关，原生控件支持，三种提示框：输入、确认、警告。首先将web提示框拦截然后再做处理。

/// 创建一个新的WebView
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    LOG_FUNCTION;
    return nil;
}
/// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    LOG_FUNCTION;
}
/// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    LOG_FUNCTION;
}
/// 警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    LOG_FUNCTION;
    NSLog(@"alert %@",message);
    completionHandler();
}

#pragma mark - 性能测试

- (void)addScrollWKWebViewAtY:(CGFloat)y {
    
    WKWebView* webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, y, kScreenWidth, TEST_ITEM_HEGITH)];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    
#if TEST_LOAD_URL
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    [webView loadRequest:request];
#endif
    
    [self.scrollView addSubview:webView];
    self.scrollView.contentSize = CGSizeMake(kScreenWidth, y+TEST_ITEM_HEGITH);
}

- (void)testWKWebView {
    CGFloat contentY = 0;
    
    double firstMem = [SystemInfoVC usedMemory];
    double lastMem = 0;
    
    for (int i=0; i < TEST_ITEM_NUM; i++) {
        [self addScrollWKWebViewAtY:contentY];
        lastMem = [SystemInfoVC usedMemory];
        NSLog(@"wkwebview%d:%.2fM",i,(lastMem-firstMem));
        firstMem = lastMem;
        
        contentY += TEST_ITEM_HEGITH;
    }
}


#pragma mark - JavaScriptCore

- (JSContext*)jsContext {
    if (_jsContext == nil) {
        //AIO打开时创建创建虚拟机和上下文
        TIME_MONITOR_BEIGIN(@"CreateJSMachine");
        JSVirtualMachine *vm = [[JSVirtualMachine alloc] init];
        TIME_MONITOR_END(@"CreateJSMachine")
        TIME_MONITOR_BEIGIN(@"CreateJSContext")
        JSContext *context = [[JSContext alloc] initWithVirtualMachine:vm];
        TIME_MONITOR_END(@"CreateJSContext");
        _jsContext = context;
    }
    return _jsContext;
}

- (void)testJSCoreValueType {
    
    JSContext* context = self.jsContext;

    //执行JavaScript代码并获取返回值
    JSValue *value = [context evaluateScript:@"1+2*3"];
    NSLog(@"value = %d", [value toInt32]);


    //数据传输
    [context evaluateScript:@"var color = {red:230, green:90, blue:100}"];

    //js->native 给你看我的颜色
    JSValue *colorValue = context[@"color"];
    NSLog(@"r=%@, g=%@, b=%@", colorValue[@"red"], colorValue[@"green"], colorValue[@"blue"]);
    NSDictionary *colorDic = [colorValue toDictionary];
    NSLog(@"r=%@, g=%@, b=%@", colorDic[@"red"], colorDic[@"green"], colorDic[@"blue"]);

    //native->js 给你点颜色看看
    context[@"color"] = @{@"red":@(0), @"green":@(0), @"blue":@(0)};
    [context evaluateScript:@"log('r:'+color.red+'g:'+color.green+' b:'+color.blue)"];
}

- (void)testJSCorePerformance {
    
    JSContext* context = self.jsContext;

    //注入Native的API，供JS调用
    TIME_MONITOR_BEIGIN(@"InjectNativeAPI")
    context[@"log"] = ^(NSString* b) {
        NSLog(b);
    };
    TIME_MONITOR_END(@"InjectNativeAPI")

    //跟随消息XML下发的JS代码，里面封装了交互逻辑
    NSString* jsVarValue = @"{ name:'gavin', print : function(name){ console.log('hello '+name); } }";
    
    //注入JS代码，根据消息ID隔离存储，即AIO所有消息共享同一个conext
    int msgId = 886;
    NSString* jsVarName = [NSString stringWithFormat:@"msg_%d",msgId];
    NSString* injectScript = [NSString stringWithFormat:@"var %@ = %@",jsVarName,jsVarValue];
    TIME_MONITOR_BEIGIN(@"InjectJSLogic");
    [context evaluateScript:injectScript];
    TIME_MONITOR_END(@"InjectJSLogic");
    
    //取得当前消息的JS上下文
    JSValue* jsMsg = context[jsVarName];
    
    //访问JS属性
    NSLog(@"property value = %@", jsMsg[@"name"]);

    //调用JS方法
    TIME_MONITOR_BEIGIN(@"NativeCallJS");
    [jsMsg[@"print"] callWithArguments:@[@"chester"]];
    TIME_MONITOR_END(@"NativeCallJS");
    
    //调用Native方法
    TIME_MONITOR_BEIGIN(@"JSCallNative");
    [context evaluateScript:@"log('hello world')"];
    TIME_MONITOR_END(@"NativeCallJS");
}


- (void)onClickBtn:(UIButton*)btn {
    JSContext* context = self.jsContext;

    NSString* newVarName = [NSString stringWithFormat:@"msg_%d",(int)btn.tag];
    [context evaluateScript:[NSString stringWithFormat:@"%@.click()",newVarName]];

}

- (void)onJSCall:(NSString*)method params:(NSArray*)params contextId:(NSString*)contextId {
    if ([method isEqualToString:@"disableButton"]) {
        UIButton* targetBtn = [self.view viewWithTag:contextId.intValue];
        [targetBtn setEnabled:NO];
        [targetBtn setBackgroundColor:[UIColor grayColor]];
    }
}

- (void)testJSCoreDemo {
    JSContext* context = self.jsContext;

    
    //注入Native API
    context[@"bridge_log"] = ^(NSString* b) {
        NSLog(b);
    };
    
    __weak typeof(self) weakSelf = self;
    context[@"bridge_callNativeMethod"] = ^(NSString* method,NSArray* params, NSString* contextID) {
        [weakSelf onJSCall:method params:params contextId:contextID];
    };
    
    //注入JS API（封装NativeAPI, 封装各端差异）
    NSString* injectJSAPI_callNativeMethod = @"function callNativeMethod() {"
        @"var msgId = this.msgId;"
        @"var method = arguments[0];"
        @"var params = [];"
        @"for (var i = 1; i < arguments.length; i++) {"
             @"params.push(arguments[i]);"
        @"}"
        @"bridge_callNativeMethod(method,params,msgId);"
    @"}";
    NSString* injectJSAPI_log = @"function log() {"
        @"bridge_log.apply(this,arguments);"
    @"}";
    [context evaluateScript:injectJSAPI_callNativeMethod];
    [context evaluateScript:injectJSAPI_log];


    //模拟构建多条消息
    int msgId = 1000;
    CGFloat originY = 0;
    for (int index = 0; index < 3; index ++) {
        [self createButtonWithMsgId:msgId originY:originY];
        msgId ++;
        originY += 200;
    }
}

- (void)createButtonWithMsgId:(int)msgId originY:(CGFloat)originY {
    JSContext* context = self.jsContext;

    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, originY, 200, 200)];
    [btn setTitle:@"点击三次置灰" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor blueColor]];
    btn.tag = msgId;
    [btn addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    //跟随消息XML下发的JS代码，里面封装了交互逻辑
    NSString* injectScript = @"var msg = { times : 0, click : function(){ this.times++; log('clickTimes='+this.times); if(this.times >= 3){ this.callNativeMethod('disableButton');}}}";
    [context evaluateScript:injectScript];
    
    //隔离存储 & 关联上下文信息
    NSString* newVarName = [NSString stringWithFormat:@"msg_%d",msgId];
    [context evaluateScript:[NSString stringWithFormat:@"var %@ = msg; %@.msgId='%d'; %@.callNativeMethod = callNativeMethod",newVarName,newVarName,msgId,newVarName]];
}


@end
