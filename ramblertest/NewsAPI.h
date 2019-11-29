//
//  NewsAPI.h
//  ramblertest
//
//  Created by Anna on 27/11/19.
//  Copyright © 2019 aloget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsAPI : NSObject

+ (NewsAPI*)sharedInstance;

- (void)loadNewsWithCompletionHandler:(void (^)())completionHandler;
- (NSArray*)getNews;

@end
