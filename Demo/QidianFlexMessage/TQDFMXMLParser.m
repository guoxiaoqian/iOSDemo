//
//  TQDFMXMLParser.m
//  Demo
//
//  Created by 郭晓倩 on 2020/1/31.
//  Copyright © 2020 郭晓倩. All rights reserved.
//

#import "TQDFMXMLParser.h"
#import "TQDFMElementBase.h"

@interface TQDFMXMLParser () <NSXMLParserDelegate>

@property (strong,nonatomic) TQDFMElementBase* rootElem;
@property (strong,nonatomic) NSMutableArray<TQDFMElementBase*>* elemStack;

@end

@implementation TQDFMXMLParser

- (TQDFMElementMsg*)parseByString:(NSString*)xml {
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    parser.delegate = self;
    [parser parse];
    
    if ([self.rootElem isKindOfClass:[TQDFMElementMsg class]] == NO) {
        return nil;
    }
    
    return (TQDFMElementMsg*)self.rootElem;
}

#pragma mark - NSXMLParser

//解析开始
-(void)parserDidStartDocument:(NSXMLParser *)parser{
    self.rootElem = nil;
    self.elemStack = [NSMutableArray new];
}

//节点头
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{
    TQDFMElementBase* elem = [self.class createNodeWithElementName:elementName];
    
    //构建父子关系
    TQDFMElementBase* parentElem = self.elemStack.lastObject;
    elem.parentElement = parentElem;
    if(parentElem.subElements == nil) {
        parentElem.subElements = [NSMutableArray new];
    }
    [parentElem.subElements addObject:elem];
    
    //处理属性
    [elem handleAttrs:attributeDict];
    
    //入栈
    [self.elemStack addObject:elem];
    if (self.elemStack.count == 1) {
        self.rootElem = elem;
    }
}

//节点内容
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
//    TQDFMElementBase* elem = self.elemStack.lastObject;
//    [elem handleInnerText:string];
}

//节点尾部
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    [self.elemStack removeLastObject];
}

//解析结束
-(void)parserDidEndDocument:(NSXMLParser *)parser{
    self.elemStack = nil;
}

//MARK: - Create Node

+ (TQDFMElementBase*)createNodeWithElementName:(NSString *)elementName {
    if ([elementName length] < 1) {
        TQDFM_INFOP_ASSERT(@"empty elementName");
        return nil;
    }
    
    Class TQDFMNodeClass = nil;
    NSString *capitalizedElementName = [elementName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[elementName substringToIndex:1] uppercaseString]];
    NSString *TQDFMNodeClassName = [NSString stringWithFormat:@"TQDFMElement%@", capitalizedElementName];
    TQDFMNodeClass = NSClassFromString(TQDFMNodeClassName);
    
    BOOL isUnknownElement = NO;
    if (nil == TQDFMNodeClass) {
        isUnknownElement = YES;
        TQDFMNodeClass = [TQDFMElementBase class];
        TQDFM_INFOP_ASSERT( ([NSString stringWithFormat:@"unknwon element %@",elementName]) );
    }
    
    if ([TQDFMNodeClass isSubclassOfClass:[TQDFMElementBase class]] == NO) {
        isUnknownElement = YES;
        TQDFMNodeClass = [TQDFMElementBase class];
        TQDFM_INFOP_ASSERT(([NSString stringWithFormat:@"wrong element %@",elementName]));
    }
    
    TQDFMElementBase* element = [[TQDFMNodeClass alloc] initWithElementName:elementName];
    element.isUnknownElement = isUnknownElement;
    return element;
}

@end
