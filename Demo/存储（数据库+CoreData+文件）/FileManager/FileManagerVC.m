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


@interface FileManagerVC () <NSXMLParserDelegate,NSStreamDelegate>

@property (strong,nonatomic) NSMutableArray* studentArray;
@property (strong,nonatomic) NSString* currentElement;

@property (strong,nonatomic) NSInputStream* inputStream;
@property (strong,nonatomic) NSOutputStream *outputStream;


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
    
    [self fileHandle];
    
    [self openStream];
    
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
    
    //路径中包含不存在的文件夹会归档失败，必须确定路径可访问
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

-(void)fileHandle{
    NSFileHandle* wirteHandle = [NSFileHandle fileHandleForWritingAtPath:[[self filePath] stringByAppendingPathComponent:@"fileHandle"]];
    [wirteHandle seekToEndOfFile];
    [wirteHandle writeData:[@"郭晓倩" dataUsingEncoding:NSUTF8StringEncoding]];
    [wirteHandle closeFile];
    
    NSFileHandle* readHandle = [NSFileHandle fileHandleForWritingAtPath:[[self filePath] stringByAppendingPathComponent:@"fileHandle"]];
    [readHandle seekToFileOffset:0];
    NSData* data = [readHandle readDataToEndOfFile];
    [readHandle closeFile];
    NSLog(@"FileHandle  read: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

-(void)openStream{
    NSOutputStream* outputSream = [NSOutputStream outputStreamToFileAtPath:[[self filePath] stringByAppendingPathComponent:@"stream"] append:NO];
    outputSream.delegate = self;
    [outputSream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [outputSream open];
    
    NSInputStream* inputStream = [NSInputStream inputStreamWithFileAtPath:[[self filePath] stringByAppendingPathComponent:@"stream"]];
    inputStream.delegate = self;
    [inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    
    self.outputStream = outputSream;
    self.inputStream = inputStream;
}

-(void)closeOutputStream{
    [self.outputStream close];
    [self.outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)closeInputStream{
    [self.inputStream close];
    [self.inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

-(BOOL)writeOutputStream{
    NSData* message = [@"郭晓倩" dataUsingEncoding:NSUTF8StringEncoding];
    NSInteger length = [self.outputStream write:[message bytes] maxLength:message.length];
    if (length >= message.length) {
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)readInputStream{
    uint8_t buffer[1024];
    NSInteger length = [self.inputStream read:buffer maxLength:1024];
    NSData* message = [NSData dataWithBytes:buffer length:length];
    NSLog(@"NSStream read: %@",[[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding]);
    if (length < 1024) {
        return YES;
    }else{
        return NO;
    }
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

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
//    NSStreamEventNone = 0,
//    NSStreamEventOpenCompleted = 1UL << 0,
//    NSStreamEventHasBytesAvailable = 1UL << 1,
//    NSStreamEventHasSpaceAvailable = 1UL << 2,
//    NSStreamEventErrorOccurred = 1UL << 3,
//    NSStreamEventEndEncountered = 1UL << 4
    if ([aStream isKindOfClass:[NSOutputStream class]]) {
        switch (eventCode) {
            case NSStreamEventOpenCompleted:{
            
            }
                break;
            case NSStreamEventHasBytesAvailable:{
                
            }
                break;
            case NSStreamEventHasSpaceAvailable:{
                if([self writeOutputStream]){
                    [self closeOutputStream];
                }
            }
                break;
            case NSStreamEventErrorOccurred:{
                [self closeOutputStream];
                [self closeInputStream];
            }
                break;
            case NSStreamEventEndEncountered:{
                [self closeOutputStream];
            }
                break;
            default:{
            
            }
                break;
        }
    }else if([aStream isKindOfClass:[NSInputStream class]]){
        switch (eventCode) {
            case NSStreamEventOpenCompleted:{
                
            }
                break;
            case NSStreamEventHasBytesAvailable:{
                if([self readInputStream]){
                    NSLog(@"inputStream hasAvailable : %d",self.inputStream.hasBytesAvailable);
                    [self closeInputStream];
                }
            }
                break;
            case NSStreamEventHasSpaceAvailable:{
                
            }
                break;
            case NSStreamEventErrorOccurred:{
                [self closeOutputStream];
                [self closeInputStream];
            }
                break;
            case NSStreamEventEndEncountered:{
                [self closeInputStream];
            }
                break;
            default:{
                
            }
                break;
        }
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

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(nullable NSString *)type defaultValue:(nullable NSString *)defaultValue {
    
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
