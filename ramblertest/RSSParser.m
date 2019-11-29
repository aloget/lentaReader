//
//  RSSParser.m
//  ramblertest
//
//  Created by Anna on 27/11/19.
//  Copyright © 2019 aloget. All rights reserved.
//

#import "RSSParser.h"

typedef enum {
    ParsingMeta,
    ParsingMetaImage, //приходится следить за уровнем вложенности из-за совпадения имен
    ParsingItem,
} ParsingStage;

@interface RSSParser() {
    NSXMLParser* parser;
    NSMutableArray* curXMLArray;
    NSMutableDictionary* curChannelInfo;
    NSMutableDictionary* curXMLDictionary;
    NSMutableString* curXMLString;

    ParsingStage stage;
}

@property (strong, nonatomic) CompletionBlock curCompletionHandler;

@end

@implementation RSSParser

#pragma mark - interface

- (void)parseURL:(NSURL *)url withCompletionHandler:(CompletionBlock)completionHandler {
    _curCompletionHandler = completionHandler;
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser parse];
}


#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    stage = ParsingMeta;
    curXMLArray = [[NSMutableArray alloc] init];
    curChannelInfo = [[NSMutableDictionary alloc] init];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    
    curXMLString = [[NSMutableString alloc] init];
    
    if (stage == ParsingMeta && [elementName isEqualToString:@"image"]) {
        stage = ParsingMetaImage;
    } else if ([elementName isEqualToString:@"item"]) {
        stage = ParsingItem;
        curXMLDictionary = [[NSMutableDictionary alloc] init];
    }
    
    if (stage == ParsingItem && [elementName isEqualToString:@"enclosure"]) { // изображение достается из тэга
        NSString* imageUrl = [attributeDict objectForKey:@"url"];
        [curXMLDictionary setObject:imageUrl forKey:@"imageUrl"];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [curXMLString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    switch (stage) {
        case ParsingMeta:
            [curChannelInfo setObject:curXMLString forKey:elementName];
            break;
        case ParsingMetaImage:
            if ([elementName isEqualToString:@"image"]) {
                stage = ParsingMeta;
            }
            break;
        case ParsingItem:
            if ([elementName isEqualToString:@"item"]) {
                [curXMLArray addObject:curXMLDictionary];
            } else {
                if (curXMLString) [curXMLDictionary setObject:curXMLString forKey:elementName];
            }
        default:
            break;
    }
    curXMLString = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"channel %@", curChannelInfo);
    NSLog(@"items %@", curXMLArray);
    
    //далее можем вернуть в удобном виде, в нашем случае просто поместим единственное требуемое нам поле в каждую из новостей
    NSString* channelTitle = [curChannelInfo objectForKey:@"title"];
    for (NSMutableDictionary* XMLDictionary in curXMLArray) {
        [XMLDictionary setObject:channelTitle forKey:@"channelTitle"];
    }

    _curCompletionHandler(curXMLArray);
    [self reset];
}

#pragma mark - utils
- (void)reset {
    parser = nil;
    curChannelInfo = nil;
    curXMLArray = nil;
    curXMLDictionary= nil;
    curXMLString = nil;
    stage = 0;
}


@end
