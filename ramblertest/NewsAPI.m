//
//  NewsAPI.m
//  ramblertest
//
//  Created by Anna on 27/11/19.
//  Copyright © 2019 aloget. All rights reserved.
//

#import "NewsAPI.h"
#import "RSSParser.h"
#import "DataManager.h"

@interface NewsAPI() {
    NSArray* sources;
}

@end

@implementation NewsAPI

+ (NewsAPI*)sharedInstance {
    static NewsAPI* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,  ^{
        instance = [[NewsAPI alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        sources = @[@"http://lenta.ru/rss", @"http://www.gazeta.ru/export/rss/lenta.xml"];
    }
    return self;
}

- (void)loadNewsWithCompletionHandler:(void (^)())completionHandler {
    dispatch_group_t sourceGroup = dispatch_group_create();
    for (NSString* source in sources) {
        NSURL* url = [NSURL URLWithString:source];
        dispatch_group_async(sourceGroup,
                             dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                RSSParser* parser = [[RSSParser alloc] init];
                                [parser parseURL:url withCompletionHandler:^(NSArray *dataArray) {
                                     [[DataManager sharedInstance] createOrUpdateNewsFromArray:dataArray];
            }];
        });
    }
    dispatch_group_notify(sourceGroup, dispatch_get_main_queue(),^{
        completionHandler();
    });
}

- (NSArray*)getNews {
    return [[DataManager sharedInstance] getNews];
}

@end
