//
//  CrashVC.m
//  Demo
//
//  Created by gavinxqguo on 2019/7/26.
//  Copyright © 2019 郭晓倩. All rights reserved.
//

#import "CrashVC.h"

@interface CrashVC ()

@property (strong,nonatomic) NSString* url;

@end

@implementation CrashVC

- (void)viewDidLoad {
    [super viewDidLoad];

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

@end
