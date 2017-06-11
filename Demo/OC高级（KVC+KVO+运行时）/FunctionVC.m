//
//  FunctionVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/5/9.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "FunctionVC.h"
#import <objc/runtime.h>

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

@end


@implementation FunctionVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self testSynthesize];
    
    [self testKVO];
    
    [self testLoadAndInitialize];
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

-(void)testLoadAndInitialize{
    [ClassInit print];
//    ClassInit* tmp = [ClassInit new];
    //    ClassInitSub* tmp2 = [ClassInitSub new];

//    Category的load也会收到调用，但顺序上在主类及其子类的load调用之后。
//    Category的Initialize会覆盖主类的。
//    initialize是在第一次主动使用当前类(调用类方法或创建对象)的时候。
//    即使子类不实现initialize方法，会把父类的实现继承过来调用一遍。
}


@end
