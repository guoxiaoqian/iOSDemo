//
//  FileManagerVC.m
//  Demo
//
//  Created by 郭晓倩 on 17/2/20.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "FileManagerVC.h"
#import "UICKeyChainStore.h"//KeyChain

@interface ArchiveModel : NSObject <NSCoding>

@property (strong,nonatomic) NSString *name;
@property (assign,nonatomic) int year;

@end

@implementation ArchiveModel

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"ArchiveModel_name"];
        self.year = [aDecoder decodeIntForKey:@"ArchiveModel_year"];

    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.name forKey:@"ArchiveModel_name"];
    [aCoder encodeInt:self.year forKey:@"ArchiveModel_year"];
}

@end

@interface Student : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *age;
@property (nonatomic, copy) NSString *nickname;

@end

@implementation Student

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end


@interface FileManagerVC () <NSXMLParserDelegate>

@property (strong,nonatomic) NSMutableArray* studentArray;
@property (strong,nonatomic) NSString* currentElement;

@end

@implementation FileManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self plist];
    
    [self archive];
    
    [self userDefault];
    
    [self keychain];
    
    [self fileManage];
    
    [self stream];
    
    [self xml];
    
    [self json];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)filePath{
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    filePath = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] absoluteString];
    return filePath;
}

-(void)plist{
    NSString* plistPath = [[self filePath] stringByAppendingPathComponent:@"dic.plist"];
    NSDictionary* dic = @{@"name":@"郭晓倩",@"year":@(100),@"brothers":@[@"夏许强",@"王涛"],@"date":[NSDate date]};
    [dic writeToFile:plistPath atomically:YES];
    
    NSString* plistPath2 = [[self filePath] stringByAppendingPathComponent:@"array.plist"];
    NSArray* array = @[@"夏许强",@"王涛",@{@"name":@"郭晓倩"}];
    [array writeToFile:plistPath2 atomically:YES];
    
    dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSLog(@"dic = %@",dic);
    array = [NSArray arrayWithContentsOfFile:plistPath2];
    NSLog(@"array = %@",array);
}

-(void)archive{
    ArchiveModel* model = [ArchiveModel new];
    model.name = @"郭晓倩";
    model.year = 11;
    NSString* archivePath = [[self filePath] stringByAppendingPathComponent:@"archive"];
    [NSKeyedArchiver archiveRootObject:model toFile:archivePath];
    
    model = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
    NSLog(@"archive name = %@",model.name);
}

-(void)userDefault{
   NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"郭晓倩" forKey:@"name"];
    [defaults setInteger:11 forKey:@"year"];
    [defaults synchronize];
    
    NSString* name = [defaults objectForKey:@"name"];
    NSLog(@"userdefaults name = %@",name);
}

-(void)keychain{
    UICKeyChainStore *keychainStore = [UICKeyChainStore keyChainStore];
    [keychainStore removeItemForKey:@"username"];
    [keychainStore setString:@"郭晓倩" forKey:@"username"];
    NSString* name = [keychainStore stringForKey:@"username"];
    NSLog(@"keychain name = %@",name);
}

-(void)fileManage{
    NSString* filePath = [[self filePath] stringByAppendingPathComponent:@"file"];
    NSFileManager* manager = [NSFileManager defaultManager];
    BOOL exist = [manager fileExistsAtPath:filePath];
    if (exist) {
        NSString* filePath2 = [[self filePath] stringByAppendingPathComponent:@"file2"];
        [manager copyItemAtPath:filePath toPath:filePath2 error:nil];
        //        [manager moveItemAtPath:filePath toPath:filePath2 error:nil];
        NSLog(@"file2 %@",[manager contentsAtPath:filePath2]);
    }else{
       NSData* data = [@"郭晓倩" dataUsingEncoding:NSUTF8StringEncoding];
        [manager createFileAtPath:filePath contents:data attributes:nil];
    }
    
    NSString* dirPath = [[self filePath] stringByAppendingPathComponent:@"dir"];
    NSString* filePath3 = [dirPath stringByAppendingPathComponent:@"file3"];
    [manager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    [manager copyItemAtPath:filePath toPath:filePath3 error:nil];
    BOOL isDirectory = NO;
    if ([manager fileExistsAtPath:dirPath isDirectory:&isDirectory]) {
        if (isDirectory) {
            NSLog(@"dir subfile = %@",[manager subpathsAtPath:dirPath]);
        }
    }
}

-(void)stream{
    //TODO-GUO:
}

-(void)xml{
    NSURL* xmlURL = [[NSBundle mainBundle] URLForResource:@"student" withExtension:@"xml"];
    NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    parser.delegate = self;
    [parser parse];
}

-(void)json{
    NSDictionary* dic = @{@"name":@"郭晓倩",@"year":@(100),@"brothers":@[@"夏许强",@"王涛"],@"date":[NSDate date]};
    if ([NSJSONSerialization isValidJSONObject:dic]) {
        NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        NSDictionary* dic2 = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"json dic=%@",dic2);
    }
}

#pragma mark - NSXMLParser

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    NSLog(@"xml parse 开始");
    self.studentArray = [NSMutableArray new];
}

//节点头
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{
    self.currentElement = elementName;
    if ([elementName isEqualToString:@"student"]) {
        
        Student* student = [Student new];
        [self.studentArray addObject:student];
    }
}

//节点值
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (self.currentElement.length) {
        Student* student = [self.studentArray lastObject];
        [student setValue:string forKey:self.currentElement];
    }
}

//节点尾部
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    self.currentElement = nil;
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    NSLog(@"xml parse result: %@",[self.studentArray valueForKey:@"name"]);
}

@end
