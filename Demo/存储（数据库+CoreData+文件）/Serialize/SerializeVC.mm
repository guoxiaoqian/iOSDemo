//
//  SerializeVC.m
//  Demo
//
//  Created by 郭晓倩 on 2019/1/13.
//  Copyright © 2019 郭晓倩. All rights reserved.
//

#import "SerializeVC.h"
#import "Person.pb.h"

#define kSerializeSpecial  0

#define kCodeKeyName @"name"
#define kCodeKeyAge @"age"
#define kCodeKeySex @"sex"
#define kCodeKeyPhone @"phone"
#define kCodeKeyChildren @"children"
#define kCodeKeyAttributes @"attributes"

@interface Person : NSObject <NSCoding>

@property (strong,nonatomic) NSDictionary* attributes;

@property (strong,nonatomic) NSString* name;
@property (assign,nonatomic) int age;
@property (assign,nonatomic) int sex;
@property (strong,nonatomic) NSString* phone;

@property (strong,nonatomic) NSArray<Person*>* children;

//XML解析辅助
@property (assign,nonatomic) BOOL parsing;

@end

@implementation Person

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
#if kSerializeSpecial
        self.name = [aDecoder decodeObjectForKey:kCodeKeyName];
        self.age = [aDecoder decodeIntForKey:kCodeKeyAge];
        self.sex = [aDecoder decodeIntForKey:kCodeKeySex];
        self.phone = [aDecoder decodeObjectForKey:kCodeKeyPhone];
#endif
        self.children = [aDecoder decodeObjectForKey:kCodeKeyChildren];
        self.attributes = [aDecoder decodeObjectForKey:kCodeKeyAttributes];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
#if kSerializeSpecial
    [aCoder encodeObject:self.name forKey:kCodeKeyName];
    [aCoder encodeInt:self.age forKey:kCodeKeyAge];
    [aCoder encodeInt:self.sex forKey:kCodeKeySex];
    [aCoder encodeObject:self.phone forKey:kCodeKeyPhone];
#endif
    [aCoder encodeObject:self.children forKey:kCodeKeyChildren];
    [aCoder encodeObject:self.attributes forKey:kCodeKeyAttributes];
}

- (instancetype)initWithPBPerson:(const PBPerson&)pbPerson {
    if (self = [super init]) {
#if kSerializeSpecial
        self.name = [NSString stringWithUTF8String:pbPerson.name().c_str()];
        self.age = pbPerson.age();
        self.sex = pbPerson.sex();
        self.phone = [NSString stringWithUTF8String:pbPerson.phone().c_str()];
#endif
        if (pbPerson.children_size() > 0) {
            NSMutableArray* children = [NSMutableArray new];
            for (int i=0; i < pbPerson.children_size(); ++i) {
                Person* child = [[Person alloc] initWithPBPerson:pbPerson.children(i)];
                [children addObject:child];
            }
            self.children = children;
        }
        if (pbPerson.attributes_size() > 0) {
            NSMutableDictionary* attributes = [NSMutableDictionary new];
            for (int i=0; i < pbPerson.attributes_size(); ++i) {
                const PBPersonAttribute& pbAttribute = pbPerson.attributes(i);
                NSString* key = [NSString stringWithUTF8String:pbAttribute.key().c_str()];
                NSString* value = [NSString stringWithUTF8String:pbAttribute.value().c_str()];
                attributes[key] = value;
            }
            self.attributes = attributes;
        }
    }
    return self;
}

- (void)encodePBPerson:(PBPerson&)pbPerson {
#if kSerializeSpecial
    if (self.name.length) {
        pbPerson.set_name([self.name UTF8String]);
    }
    pbPerson.set_age(self.age);
    pbPerson.set_sex(self.sex);
    if (self.phone.length) {
        pbPerson.set_phone([self.phone UTF8String]);
    }
#endif
    for (Person* child in self.children) {
        PBPerson& pbChild = *pbPerson.add_children();
        [child encodePBPerson:pbChild];
    }
    
    [self.attributes enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, NSString*  _Nonnull obj, BOOL * _Nonnull stop) {
        PBPersonAttribute& pbAttribute = *pbPerson.add_attributes();
        pbAttribute.set_key([key UTF8String]);
        pbAttribute.set_value([obj UTF8String]);
    }];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    //处理未知字段
}

@end

#pragma mark - SerializeVC

@interface SerializeVC () <NSXMLParserDelegate>

@property (strong,nonatomic) Person* personFromXML;
@property (strong,nonatomic) Person* personFromArchive;
@property (strong,nonatomic) Person* personFromPB;

//XML辅助
@property (strong,nonatomic) NSMutableArray<Person*>* personStack;

@end

@implementation SerializeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self parseXml];
    [self parseArchive];
    [self parsePB];
}

-(void)parseXml{
    NSURL* xmlURL = [[NSBundle mainBundle] URLForResource:@"Person" withExtension:@"xml"];
    NSData* xmlData = [NSData dataWithContentsOfURL:xmlURL];
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:xmlData];
    parser.delegate = self;
    NSLog(@"Length XML %@",@(xmlData.length));
    TIME_MONITOR_BEIGIN(@"Parse XML");
    [parser parse];
    TIME_MONITOR_END(@"Parse XML");
}

-(void)parseArchive{
    TIME_MONITOR_BEIGIN(@"Serialize Archive");
    NSData* archiveData = [NSKeyedArchiver archivedDataWithRootObject:self.personFromXML];
    TIME_MONITOR_END(@"Serialize Archive");
    NSLog(@"Length Archive %@",@(archiveData.length));

    TIME_MONITOR_BEIGIN(@"Parse Archive");
    self.personFromArchive = [NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
    TIME_MONITOR_END(@"Parse Archive");
}

- (void)parsePB {
    
    TIME_MONITOR_BEIGIN(@"Serialize PB");
    PBPerson person;
    [self.personFromXML encodePBPerson:person];
    std::string pbData = person.SerializeAsString();
    TIME_MONITOR_END(@"Serialize PB");
    
    NSLog(@"Length PB %@",@(pbData.size()));
    
    TIME_MONITOR_BEIGIN(@"Parse PB");
    PBPerson person2;
    person2.ParseFromString(pbData);
    self.personFromPB = [[Person alloc] initWithPBPerson:person2];
    TIME_MONITOR_END(@"Parse PB");
}

-(void)json{
//    NSDictionary* dic = @{@"name":@"郭晓倩",@"year":@(100),@"brothers":@[@"夏许强",@"王涛"],@"date":[NSDate date]};
//    if ([NSJSONSerialization isValidJSONObject:dic]) {
//        NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
//        NSDictionary* dic2 = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        NSLog(@"json dic=%@",dic2);
//    }
}

#pragma mark - NSXMLParser

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    self.personStack = [NSMutableArray new];
}

//节点头
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{

    if ([elementName isEqualToString:@"Person"]) {
        Person* person = [Person new];
        person.attributes = attributeDict;
#if kSerializeSpecial
        [person setValuesForKeysWithDictionary:attributeDict];
#endif
        person.parsing = YES;
        [self.personStack addObject:person];
    }
}

//节点尾部
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"Person"]) {
        Person* person = [self.personStack lastObject];
        if (person.parsing) {
            person.parsing = NO;
        } else{
            int i = (int)self.personStack.count-2;
            for (; i >= 0; --i) {
                Person* tmpPerson = self.personStack[i];
                if (tmpPerson.parsing) {
                    tmpPerson.parsing = NO;
                    break;
                }
            }
            
            Person* parent = self.personStack[i];
            NSRange childRange = NSMakeRange(i+1, self.personStack.count-1-i);
            parent.children = [self.personStack subarrayWithRange:childRange];
            [self.personStack removeObjectsInRange:childRange];
        }
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    self.personFromXML = self.personStack.firstObject;
}

@end
