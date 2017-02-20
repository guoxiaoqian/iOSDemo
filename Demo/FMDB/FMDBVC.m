//
//  FMDBVC.m
//  Demo
//
//  Created by 郭晓倩 on 17/2/15.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "FMDBVC.h"
#import "FMDB.h"

@interface FMDBVC ()

@property (strong,nonatomic) FMDatabase* db;

@end

@implementation FMDBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString* dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"fmdb.sqlite3"];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    
    self.db = db;
    
    if ([db open]) {
        
        [self createTable];
        
//        [self addUser];
//        
//        [self updateUser];
//        
//        [self fetchUser];
//        
        [self deleteUser];
        
        [self addBatchUser];
        [self fetchUserWithLimit:10 offset:3];
        
        [db close];
    }else{
        NSLog(@"DB Open Failed");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createTable{
    NSString* sql = @"create table if not exists tab_user(name TEXT)";
    if (![self.db executeUpdate:sql]) {
        NSLog(@"Create table failed");
    };
    
}

-(void)addUser{
    NSString* sql = @"insert into tab_user(name) values ('郭晓倩')";
    if (![self.db executeUpdate:sql]) {
        NSLog(@"insert table failed");
    };
}

-(void)addBatchUser{
    NSMutableString* sql = [NSMutableString new];
    for (int i=0; i<20; ++i) {
        [sql appendFormat:@"insert into tab_user(name) values ('郭晓倩%d');",i];
    }
    if (![self.db executeStatements:sql]) {
        NSLog(@"batch insert table failed");
    };
}

-(void)updateUser{
    NSString* sql = @"update tab_user set name = '牛兆娟'";
    if (![self.db executeUpdate:sql]) {
        NSLog(@"update table failed");
    };
}

-(void)fetchUser{
    NSString* sql = @"select * from tab_user where name = '牛兆娟'";
    FMResultSet* result = [self.db executeQuery:sql];
    while ([result next]) {
        NSLog(@"name = %@",[result stringForColumn:@"name"]);
    };
}

-(void)fetchUserWithLimit:(int)limit offset:(int)offset{
    NSString* sql = [NSString stringWithFormat:@"select * from tab_user order by name desc limit %d offset %d",limit,offset];
    FMResultSet* result = [self.db executeQuery:sql];
    while ([result next]) {
        NSLog(@"page name = %@",[result stringForColumn:@"name"]);
    };
}

-(void)deleteUser{
    NSString* sql = @"delete from tab_user";
    if (![self.db executeUpdate:sql]) {
        NSLog(@"delete table failed");
    };
}


@end
