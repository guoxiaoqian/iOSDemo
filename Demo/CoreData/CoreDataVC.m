//
//  CoreDataVC.m
//  Demo
//
//  Created by 郭晓倩 on 17/2/15.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "CoreDataVC.h"
#import <CoreData/CoreData.h>
#import "User+CoreDataClass.h"

@interface CoreDataVC ()

@property (strong,nonatomic) NSManagedObjectContext* context;
@property (strong,nonatomic) NSManagedObjectModel* model;

@end

@implementation CoreDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initCoreData];
    
    [self deleteUser];
    
    [self addUser];
    
    //    [self fetchUser];
    //
    //    [self updateUser];
    //
    //    [self fetchUser];
    //
    //    [self deleteUser];
    
    //    [self fetchUserWithLimit:3 offset:3];
    
    [self predicateQuery];
    
    [self regularExpressionQuery];
}

-(void)initCoreData{
    
    //    NSManagedObjectModel* model = [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]]];
    NSManagedObjectModel* model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"]];//注意扩展名
    
    
    NSPersistentStoreCoordinator* coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    //    NSString* dbFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"user.sqlite3"];
    //    NSURL* dbFileURL = [NSURL fileURLWithPath:dbFilePath];
    //    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:dbFileURL options:nil error:nil];
    NSString* dbFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"user.file"];
    NSURL* dbFileURL = [NSURL fileURLWithPath:dbFilePath];
    [coordinator addPersistentStoreWithType:NSBinaryStoreType configuration:nil URL:dbFileURL options:nil error:nil];
    
    NSLog(@"persistent file path %@",dbFilePath);
    
    NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [context setPersistentStoreCoordinator:coordinator];
    
    self.model = model;
    self.context = context;
}

-(void)addUser{
    NSEntityDescription* description = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.context];
    for (int i=0; i<10; ++i) {
        User* user = [[User alloc] initWithEntity:description insertIntoManagedObjectContext:self.context];
        user.name = [NSString stringWithFormat:@"郭晓倩%d",i];
    }
    
    [self.context save:nil];
}

-(void)fetchUser{
    //    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    //    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name contains '郭晓倩'"];
    
    NSFetchRequest* fetchRequest = [self.model fetchRequestTemplateForName:@"nameMatch"];
    NSError* error = nil;
    NSArray * result = [self.context executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        for (User* user in result) {
            NSLog(@"%@",user.name);
        }
    }else{
        NSLog(@"fetch error");
    }
}

-(void)fetchUserWithLimit:(int)limit offset:(int)offset{
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name contains '郭晓倩'"];
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    fetchRequest.fetchLimit = limit;
    fetchRequest.fetchOffset = offset;
    NSError* error = nil;
    NSArray * result = [self.context executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        for (User* user in result) {
            NSLog(@"%@",user.name);
        }
    }else{
        NSLog(@"page fetch error");
    }
}

-(void)predicateQuery{
    
    NSCompoundPredicate* compoundPredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"name MATCHES %@",@"^郭[晓倩]{2}[0-9]$"],
                                                         [NSPredicate predicateWithFormat:@"name IN {'郭晓倩1','郭晓倩2'}"]]] ;
    
    NSMutableArray* predicateArray = [NSMutableArray arrayWithObjects:
                                      [NSPredicate predicateWithFormat:@"name MATCHES %@",@"^郭[晓倩]{2}[0-9]$"],
                                      [NSPredicate predicateWithFormat:@"name IN {'郭晓倩1','郭晓倩2'}"],
                                      [NSPredicate predicateWithFormat:@"(name = %@ OR name == %@) && (name != %@)",@"郭晓倩1",@"郭晓倩2",@"郭晓倩3"],
                                      [NSPredicate predicateWithFormat:@"name BEGINSWITH %@",@"郭"],
                                      compoundPredicate,
                                      nil];
    
    for (NSPredicate* predicate in predicateArray) {
        [self fetchUserWithPredicate:predicate];
    }
    
}

-(void)regularExpressionQuery{
    NSMutableArray* regxArray = [NSMutableArray arrayWithObjects:
                                 [NSRegularExpression regularExpressionWithPattern:@"^郭.*" options:NSRegularExpressionCaseInsensitive error:nil],
                                 [NSRegularExpression regularExpressionWithPattern:@"^.{3}" options:NSRegularExpressionCaseInsensitive error:nil],
                                 nil];
    for (NSRegularExpression* regx in regxArray) {
        [self fetchUserWithPredicate:[NSPredicate predicateWithFormat:@"name MATCHES %@",regx.pattern]];
    }
}

-(void)fetchUserWithPredicate:(NSPredicate*)predicate{
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    fetchRequest.predicate = predicate;
    NSLog(@"=======predicate %@",predicate.predicateFormat);
    NSError* error = nil;
    NSArray * result = [self.context executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        for (User* user in result) {
            NSLog(@"%@",user.name);
        }
    }else{
        NSLog(@"fetch error");
    }
}

- (void)deleteUser{
    NSFetchRequest* fetchRequest = [self.model fetchRequestTemplateForName:@"nameMatch"];
    NSError* error = nil;
    NSArray * result = [self.context executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        for (User* user in result) {
            [self.context deleteObject:user];
            NSLog(@"delete user %@",user.name);
        }
    }else{
        NSLog(@"fetch error");
    }
    [self.context save:nil];
}

-(void)updateUser{
    NSFetchRequest* fetchRequest = [self.model fetchRequestTemplateForName:@"nameMatch"];
    NSError* error = nil;
    NSArray * result = [self.context executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        for (User* user in result) {
            user.name = [user.name stringByReplacingOccurrencesOfString:@"郭晓倩" withString:@"牛兆娟"];
            NSLog(@"delete user %@",user.name);
        }
    }else{
        NSLog(@"fetch error");
    }
    [self.context save:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
