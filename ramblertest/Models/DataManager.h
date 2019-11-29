//
//  DataManager.h
//  ramblertest
//
//  Created by Anna on 27/11/19.
//  Copyright © 2019 aloget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsItem.h"

@interface DataManager : NSObject

+ (DataManager*)sharedInstance;

- (void)createOrUpdateNewsFromArray:(NSArray*)array;
- (NSArray*)getNews;
- (NSArray*)getNewsWithOptions:(NSDictionary *)options;
- (void)setFavorite:(BOOL)isFavorite forNews:(NewsItem *)news withCompletionHandler:(void (^)())completionHandler;
- (NSArray *)getFavorites;

@end
