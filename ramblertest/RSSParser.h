//
//  RSSParser.h
//  ramblertest
//
//  Created by Anna on 27/11/19.
//  Copyright © 2019 aloget. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionBlock) (NSArray* dataArray);

@interface RSSParser : NSObject <NSXMLParserDelegate>

- (void)parseURL:(NSURL*)url withCompletionHandler:(CompletionBlock)completionHandler;

@end
