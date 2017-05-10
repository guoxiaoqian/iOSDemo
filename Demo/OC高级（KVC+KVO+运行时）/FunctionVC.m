//
//  FunctionVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/5/9.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "FunctionVC.h"
#import <objc/runtime.h>

@interface FunctionVC ()

@property (strong,nonatomic) NSString* age;

@end




@implementation FunctionVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self testSynthesize];
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


@end
