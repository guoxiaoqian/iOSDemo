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
    return NO;
}

+(BOOL)resolveClassMethod:(SEL)sel{
#warning TODO-GUO
    NSString* selName = NSStringFromSelector(sel);
    if ([selName isEqualToString:@"classMethodNotImplemented"]) {
        class_addMethod([self class], sel, (IMP)clasMethodImplemention, "v:");
        return YES;
    }
    return NO;
}

-(id)forwardingTargetForSelector:(SEL)aSelector{
    NSString* selName = NSStringFromSelector(aSelector);
    if ([selName isEqualToString:@"methodNotImplemented2"]) {
        return [[MessageDeliverBackup alloc] init];
    }
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    //当forwardingTargetForSelector返回nil时调用；结果给forwardInvocation用
    //未定义或未实现的都返回nil
    //返回nil直接抛异常：unrecognized selector sent to instance
    NSString* selName = NSStringFromSelector(aSelector);
    if ([selName isEqualToString:@"methodNotImplemented3"]) {
        NSMethodSignature* sig = [NSMethodSignature signatureWithObjCTypes:"v@:"];
        return sig;
    }
    return nil;
}


-(void)forwardInvocation:(NSInvocation *)anInvocation{
    NSString* selName = NSStringFromSelector(anInvocation.selector);
    if ([selName isEqualToString:@"methodNotImplemented3"]) {
        NSLog(@"methodNotImplemented3 invoke");
    }else{
        [self doesNotRecognizeSelector:anInvocation.selector];
    }
}

-(BOOL)respondsToSelector:(SEL)aSelector{ //需重写,仅调用respondsToSelector时有用
    NSString* selName = NSStringFromSelector(aSelector);
    if([selName isEqualToString:@"methodNotImplemented1"] ||
       [selName isEqualToString:@"methodNotImplemented2"] ||
       [selName isEqualToString:@"methodNotImplemented3"] ||
       [selName isEqualToString:@"classMethodNotImplemented"]
       ){
        return YES;
    }
    return [super respondsToSelector:aSelector];
}

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

-(void)messageDeliver{
    MessageDeliver* deliver = [MessageDeliver new];
//    [deliver methodNotImplemented1];
//    [deliver methodNotImplemented2];
//    [deliver methodNotImplemented3];
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wobjc-method-access"
//    [deliver methodNotDefined];
//#pragma clang diagnostic pop

    [[deliver class] classMethodNotImplemented];

}


@end
