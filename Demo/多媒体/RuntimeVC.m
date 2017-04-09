//
//  RuntimeVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/4/8.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "RuntimeVC.h"
#import <objc/runtime.h>

@interface MessageDeliverBackup : NSObject
-(void)methodNotImplemented2;
@end

@implementation MessageDeliverBackup

-(void)methodNotImplemented2{
    NSLog(@"methodNotImplemented2 exectue");
}

@end

void methodImplemention(id self,SEL _cmd){
    NSLog(@"methodImplemention execute for sel:%@",NSStringFromSelector(_cmd));
}

void clasMethodImplemention(id self,SEL _cmd){
    NSLog(@"clasMethodImplemention execute for sel:%@",NSStringFromSelector(_cmd));
}


@interface MessageDeliver : NSObject

-(void)methodNotImplemented1;

-(void)methodNotImplemented2;

-(void)methodNotImplemented3;

+(void)classMethodNotImplemented;

@end

@implementation MessageDeliver

+(BOOL)resolveInstanceMethod:(SEL)sel{
    NSString* selName = NSStringFromSelector(sel);
    if ([selName isEqualToString:@"methodNotImplemented1"]) {
        class_addMethod([self class], sel, (IMP)methodImplemention, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

+(BOOL)resolveClassMethod:(SEL)sel{
    if (sel == @selector(classMethodNotImplemented)) {
        //参数class必须是元类型，元类中储存的是类对象的元数据，比如类方法就储存在这里。
        // object_getClass(obj)返回的是obj中的isa指针；而[obj class]则分两种情况：一是当obj为实例对象时，[obj class]中class是实例方法：- (Class)class，返回的obj对象中的isa指针；二是当obj为类对象（包括元类和根类以及根元类）时，调用的是类方法：+ (Class)class，返回的结果为其本身。
        class_addMethod(object_getClass([self class]), sel, (IMP)clasMethodImplemention, "v@:");
        return YES;
    }
    return [super resolveClassMethod:sel];
}

-(id)forwardingTargetForSelector:(SEL)aSelector{
    NSString* selName = NSStringFromSelector(aSelector);
    if ([selName isEqualToString:@"methodNotImplemented2"]) {
        return [[MessageDeliverBackup alloc] init];
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSString* selName = NSStringFromSelector(aSelector);
    if ([selName isEqualToString:@"methodNotImplemented3"]) {
        NSMethodSignature* sig = [NSMethodSignature signatureWithObjCTypes:"v@:"];
        return sig;
    }
    return [super methodSignatureForSelector:aSelector];
}

-(void)forwardInvocation:(NSInvocation *)anInvocation{
    NSString* selName = NSStringFromSelector(anInvocation.selector);
    if ([selName isEqualToString:@"methodNotImplemented3"]) {
        NSLog(@"methodNotImplemented3 invoke");
    }else{
        [super forwardInvocation:anInvocation];
    }
}

//-(BOOL)respondsToSelector:(SEL)aSelector{
//    //需重写,仅调用respondsToSelector时有用
//    NSString* selName = NSStringFromSelector(aSelector);
//    if([selName isEqualToString:@"methodNotImplemented1"] ||
//       [selName isEqualToString:@"methodNotImplemented2"] ||
//       [selName isEqualToString:@"methodNotImplemented3"] ||
//       [selName isEqualToString:@"classMethodNotImplemented"]
//       ){
//        return YES;
//    }
//    return [super respondsToSelector:aSelector];
//}

//Objective-C type encodings  (@encode(int))
//
//c     A char
//i     An int
//s     A short
//l     A long  l is treated as a 32-bit quantity on 64-bit programs.
//q     A long long
//C     An unsigned char
//I     An unsigned int
//S     An unsigned short
//L     An unsigned long
//Q     An unsigned long long
//f     A float
//d     A double
//B     A C++ bool or a C99 _Bool
//v     A void
//*     A character string (char *)
//@     An object (whether statically typed or typed id)
//#     A class object (Class)
//:     A method selector (SEL)
//[array type]      An array
//{name=type...}    A structure
//(name=type...)    A union
//bnum              A bit field of num bits
//^type             A pointer to type
//?         An unknown type (among other things, this code is used for function pointers)

@end




@interface RuntimeVC ()

@end

@implementation RuntimeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self messageDeliver];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 消息转发

//第一步：先找方法
//1,首先去该类的方法cache中查找,如果找到了就返回它;
//2,如果没有找到,就去该类的方法列表中查找。如果在该类的方法列表中找到了,则将 IMP 返回,并将 它加入 cache 中缓存起来。根据最近使用原则,这个方法再次调用的可能性很大,缓存起来可以节省下次 调用再次查找的开销。
//3,如果在该类的方法列表中没找到对应的IMP,在通过该类结构中的super_class指针在其父类结构的方法列表中去查找,直到在某个父类的方法列表中找到对应的IMP,返回它,并加入cache中;
//第二步：动态方法决议
//如果在自身以及所有父类的方法列表中都没有找到对应的 IMP,则看是不是可以进行动态方法决议;
//resolveInstanceMethod和resolveClassMethod可以为类添加IMP，返回YES表示已决议，否则进入消息转发流程
//第三部：消息转发
//1.转发给其他对象：forwardingTargetForSelector，返回self或nil则走第2步
//2.调用methodSignatureForSelector，获取方法签名（包含方法名、参数、返回类型）， 返回nil直接抛异常：unrecognized selector sent to instance
//3.通过方法签名构造NSInvocation对象，并调用forwardInvocation，最后一次处理消息的机会。
//第四部： 报错

-(void)messageDeliver{
    MessageDeliver* deliver = [MessageDeliver new];
    [deliver methodNotImplemented1]; //动态方法解析
    [deliver methodNotImplemented2]; //消息转发第一步
    [deliver methodNotImplemented3]; //消息转发第二步和第三步
    
    [[deliver class] classMethodNotImplemented]; //动态方法解析（类方法）
}

#pragma mark - 运行时修改属性、方法、类

-(void)runtimeProperty{
    
}

-(void)runtimeMethod{
    
}

-(void)runtimeClass{
    
    
}


@end
