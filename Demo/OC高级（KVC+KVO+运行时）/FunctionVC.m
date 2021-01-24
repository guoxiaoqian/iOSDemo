//
//  FunctionVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/5/9.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "FunctionVC.h"
#import <objc/runtime.h>
#import "MRCTest.h"
#import "DebugTool.h"
#import "Singleton.h"

@interface MyEqualObj : NSObject

@property (nonatomic,assign) int value;

@end

@implementation MyEqualObj

- (BOOL)isEqual:(MyEqualObj*)object {
    if (object && self.value == object.value) {
        return YES;
    }
    return [super isEqual:object];
}

@end

#pragma mark - Load & Initilize

@interface ClassInit : NSObject

+(void)print;

@end

@implementation ClassInit

+(void)load{
    LOG_FUNCTION;
}

+(void)initialize{
    LOG_FUNCTION;
}

+(void)print{
    LOG_FUNCTION;
}

@end

@interface ClassInit (Test)

@end

@implementation ClassInit (Test)

+(void)load{
    LOG_FUNCTION;
}

+(void)initialize{
    LOG_FUNCTION;
}

@end

@interface ClassInitSub : ClassInit

@end

@implementation ClassInitSub

+(void)load{
    LOG_FUNCTION;
}

+(void)initialize{
    LOG_FUNCTION;
}

@end

#pragma mark - FunctionVC

@interface FunctionVC ()

@property (strong,nonatomic) NSString* age;
@property (strong,nonatomic) NSString* name;

//KVC
@property (assign,nonatomic) CGFloat grade;
@property (assign,nonatomic) BOOL isBoy;

@end

@implementation FunctionVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    [self testSynthesize];
    
//    [self testDynamic];
    
//    [self testKVO];
//    
//    [self testLoadAndInitialize];
//    
//    [self testBlock];
    
//    [MRCTest testMRC];
    
//    [[MRCTest new] testMRCObj];
    
//    [DebugTool testDebugTool];
    
//    [self testKVC];
    
//    [Singleton testSingleton];
    
//    [self testCollectionEqual];
    
    [self testNSStringClass];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    LOG_FUNCTION;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    LOG_FUNCTION;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - synthesize

//在Xcode4.4版本之前@property和@synthesize的功能是独立分工的：
//@property的作用是：自动的生成成员变量set/get方法的声明如代码：
//@synthesize的作用：将@property中定义的属性自动生成get/set的实现方法而且默认访问成员变量age
//@synthesize age; //只生成age变量

//如果指定访问成员变量_age的话代码如：
@synthesize age = _age; //只生成_age变量


-(void)testSynthesize{
    //获取变量
    unsigned int count = 0;
    Ivar* varList = class_copyIvarList([self class], &count);
    for (int i=0; i<count; ++i) {
        Ivar var = varList[i];
        NSLog(@"synthesize var name %s",ivar_getName(var));
    }
    free(varList); //必须释放
}


#pragma mark - Dynamic

//动态不会生成实例变量,也不会生成Set和Get方法，需要运行时自己生成。使用set方法编译时可通过，运行时若没实现就崩溃
@dynamic name;

-(void)testDynamic{
    self.name = @"hello";
    //获取变量
    unsigned int count = 0;
    Ivar* varList = class_copyIvarList([self class], &count);
    for (int i=0; i<count; ++i) {
        Ivar var = varList[i];
        NSLog(@"dynamic var name %s",ivar_getName(var));
    }
    free(varList); //必须释放
}

#pragma mark - bridge

-(void)testBridge{
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.baidu.com"];
    
    //仅是类型转换，没有所有权转移
    CFURLRef ref = (__bridge CFURLRef)url;
    
    //NS-->CF所有权转移，需要手动CFRelease
    ref = (__bridge_retained CFURLRef)url;
    
    //CF-->NS所有权转移，由ARC控制计数
    url = (__bridge_transfer NSURL*)ref;
}

#pragma mark - KVO


-(void)testKVO{
    [self addObserver:self forKeyPath:@"age"
            options: NSKeyValueObservingOptionNew
            context:nil];

    NSLog(@"KVO %@",NSStringFromClass(self.class));
    self.age = @"100";
    [self removeObserver:self forKeyPath:@"age"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"KVO class:%@ key:%@ change:%@",NSStringFromClass([object class]),keyPath,change);
}

#pragma mark - KVC

- (void)testKVC {
    NSDictionary* attributes = @{
                                 @"grade":@"11",
                                 @"isBoy":@"true",
                                 @"height":@"10" //undefined key
                                 };
    [self setValuesForKeysWithDictionary:attributes];
    
    //同名key，value类型不同会自动转换，比如@"true"转换成YES
    
    NSLog(@"KVC grade:%f isBoy:%d",self.grade,self.isBoy);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"KVC UndefinedKey:%@",key);
}



#pragma mark - Load & Initialize

-(void)testLoadAndInitialize{
    [ClassInit print];
//    ClassInit* tmp = [ClassInit new];
    //    ClassInitSub* tmp2 = [ClassInitSub new];

//    Category的load也会收到调用，但顺序上在主类及其子类的load调用之后。
//    Category的Initialize会覆盖主类的。
//    initialize是在第一次主动使用当前类(调用类方法或创建对象)的时候。
//    即使子类不实现initialize方法，会把父类的实现继承过来调用一遍。
}

#pragma mark - Block

-(void)testBlock{

    void(^block1)(void) = ^{
        NSLog(@"Block 1");
    };
    
    NSLog(@"block 未捕获:%@",block1);
    
    int a = 0;
    NSMutableString* string = [[NSMutableString alloc] initWithString:@"郭晓倩"];
    NSLog(@"block 捕获前 %p %p",&a,&string);
    void(^block2)(void) = ^{
        string.string = @"呵呵";
        NSLog(@"block 捕获中 %p %p",&a,&string);
    };
    
    block2();
    NSLog(@"block 捕获后:%@ %p",block2,&a);

    __block int b = 1;
    __block NSMutableString* string2 = [[NSMutableString alloc] initWithString:@"郭晓倩"];
    NSLog(@"block __block捕获前 %p %p",&b,&string2);
    void(^block3)(void) = ^{
        NSLog(@"Block __block捕获中 %p %p",&b,&string2);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"Block __block捕获中 delay %p",&b);
        });
    };
    block3();

    NSLog(@"block __block捕获后:%@ %p %p",block3,&b,&string2);
    
//  在没有捕获任何自动变量的时候, Block 的类型为NSGlobalBlock.
//  捕获自动变量的时候, Block 的类型为NSStackBlock.
//  对 Block 在堆上进行复制的时候, 复制后的类型为NSMallocBlock.
//    
//  将 Block 作为函数的返回值时, 编译器会自动生成复制到堆上的代码. Blocks 从栈上复制到堆中, 这样即使 Block 的变量作用域结束, 堆上的 Block 还可以继续存在.
    
//  在ARC开启的情况下，将只会有NSConcreteGlobalBlock和 NSConcreteMallocBlock类型的block。原本的NSConcreteStackBlock的block会被NSConcreteMallocBlock类型的block替代。
    
    //基本类型和对象类型没有__block声明，原始变量一直存储在栈里；ARC下由于是MallocBlock，所以block捕获的变量也存储在堆上,但是不能重新赋值。。
    //基本类型和对象类型使用__block声明，而没被任何block引用，则原始变量还是存储在栈里；若被block引用了，则原始变量会拷贝到堆上
}

#pragma mark - CollectionEqual

- (void)testCollectionEqual {
    MyEqualObj* obj1 = [MyEqualObj new];
    obj1.value = 1;
    MyEqualObj* obj2 = [MyEqualObj new];
    obj2.value = 1;
    NSMutableArray* array = [NSMutableArray new];
    [array addObject:obj1];
    [array removeObject:obj2];
    NSLog(@"testCollectionEqual count=%d",(int)array.count);
}

#pragma mark - NSStringClass

- (void)testNSStringClass {
    
    //存储类型参考文章： https://www.jianshu.com/p/dcbf48a733f9
    //存储长度参考文章：https://www.jianshu.com/p/df630e78df32
    
    NSString *str = @"abc"; // __NSCFConstantString
    NSString *str1 = @"abc"; //__NSCFConstantString
    NSString *str2 = [NSString stringWithFormat:@"%@", str]; // NSTaggedPointerString
    NSString *str3 = [str copy]; // __NSCFConstantString
    NSString *str4 = [str mutableCopy]; // __NSCFString

    NSString *str5 = [NSString stringWithFormat:@"%tu",300703443];

    NSLog(@"str(%@<%p>: %p): %@", [str class], &str, str, str);
    NSLog(@"str1(%@<%p>: %p): %@", [str1 class], &str1, str1, str1);
    NSLog(@"str2(%@<%p>: %p): %@", [str2 class], &str2, str2, str2);
    NSLog(@"str3(%@<%p>: %p): %@", [str3 class], &str3, str3, str3);
    NSLog(@"str4(%@<%p>: %p): %@", [str4 class], &str4, str4, str4);
    NSLog(@"str5(%@<%p>: %p): %@", [str5 class], &str5, str5, str5);
}

// MARK:- 视图查找

+ (id)findNextObjectOfClass:(Class)class fromObject:(id)fromObj byNextBlock:(id(^)(id fromObj))nextBlock {
    if ([fromObj isKindOfClass:class]) {
        return fromObj;
    }
    id nextObj = nextBlock(fromObj);
    while (nextObj && [nextObj isKindOfClass:class] == NO) {
        nextObj = nextBlock(nextObj);
    }
    return nextObj;
}

+ (UIView*)findSuperViewOfClass:(Class)class fromView:(UIView*)fromView {
    return [self findNextObjectOfClass:class fromObject:fromView byNextBlock:^id(id fromObj) {
        if ([fromObj isKindOfClass:[UIView class]]) {
            return ((UIView*)fromObj).superview;
        } else {
            return nil;
        }
    }];
}

+ (UIView*)findNextResponderOfClass:(Class)class fromResponder:(UIResponder*)fromResponder {
    return [self findNextObjectOfClass:class fromObject:fromResponder byNextBlock:^id(id fromObj) {
        if ([fromObj isKindOfClass:[UIResponder class]]) {
            return ((UIResponder*)fromObj).nextResponder;
        } else {
            return nil;
        }
    }];
}

+ (UIViewController*)getCurrentViewControllerWithView:(UIView*)view {
    return (UIViewController*)[self findNextResponderOfClass:[UIViewController class] fromResponder:view];
}

+ (UINavigationController*)getCurrentNavigationViewControllerWithView:(UIView*)view {
    return (UINavigationController*)[self findNextResponderOfClass:[UINavigationController class] fromResponder:view];
}

@end
