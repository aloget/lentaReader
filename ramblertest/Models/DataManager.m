//
//  DataManager.m
//  ramblertest
//
//  Created by Anna on 27/11/19.
//  Copyright © 2019 aloget. All rights reserved.
//

#import "DataManager.h"
#import "NewsItem.h"
#import "AppDelegate.h"
#import "FilterViewController.h"

@interface DataManager() {
    NSManagedObjectContext* mainContext;
}
@end

@implementation DataManager

+ (DataManager*)sharedInstance {
    static DataManager* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,  ^{
        instance = [[DataManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        mainContext = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    }
    return self;
}


- (void)createOrUpdateNewsFromArray:(NSArray*)array {
    NSManagedObjectContext* privateContext = [self privateContext];
    for (NSDictionary* newsDictionary in array) {
        __block NewsItem* newsItem;
        [privateContext performBlockAndWait:^{
            newsItem = (NewsItem*)[self objectWithID:newsDictionary[@"guid"] entity:@"NewsItem" context:privateContext];
        }];
        if ([newsDictionary[@"title"] isKindOfClass:[NSString class]]) {
            newsItem.title = newsDictionary[@"title"];
        }
        if ([newsDictionary[@"description"] isKindOfClass:[NSString class]]) {
            newsItem.text = newsDictionary[@"description"];
        }
        if ([newsDictionary[@"channelTitle"] isKindOfClass:[NSString class]]) {
            newsItem.channelTitle = newsDictionary[@"channelTitle"];
        }
        if ([newsDictionary[@"imageUrl"] isKindOfClass:[NSString class]]) {
            newsItem.imageUrl = newsDictionary[@"imageUrl"];
        }
        if ([newsDictionary[@"pubDate"] isKindOfClass:[NSString class]]) {
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"ccc, dd MMM yyyy HH:mm:ss Z";
            newsItem.pubDate = [formatter dateFromString:newsDictionary[@"pubDate"]];
        }
    }
    [privateContext performBlockAndWait:^{
        NSError* error = nil;
        if ([privateContext hasChanges] && ![privateContext save:&error]) {
            NSLog(@"createOrUpdateNewsFromArray error %@", error);
        }
    }];
}

- (NSArray*)getNews {
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"NewsItem"];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    NSError* error = nil;
    NSArray* news = [mainContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error occured while fetching: %@", error);
    }
    return news;
}

-(NSArray*)getNewsWithOptions:(NSDictionary *)options {
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"NewsItem"];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
        
    NSPredicate *predicate =  [self prepareFilterPredicateForOptions:options];
    [request setPredicate:predicate];
    
    NSError* error = nil;
    NSArray* news = [mainContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error occured while fetching: %@", error);
    }
    NSLog(@"Fetched objects: %@", news);
    return news;
}

- (void)setFavorite:(BOOL)isFavorite forNews:(NewsItem *)news withCompletionHandler: (void (^)())completionHandler {
    NSManagedObjectContext* privateContext = [self privateContext];
     __block NewsItem* newsItem;
     [privateContext performBlockAndWait:^{
         newsItem = (NewsItem*)[self objectWithID:news.identificator entity:@"NewsItem" context:privateContext];
     }];
     newsItem.isFavorite = @(isFavorite);
     [privateContext performBlockAndWait:^{
         NSError* error = nil;
         if ([privateContext hasChanges] && ![privateContext save:&error]) {
             NSLog(@"setFavorite error %@", error);
         }
         completionHandler();
     }];
}

- (NSArray *)getFavorites {
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"NewsItem"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavorite == 1"];
    [request setPredicate:predicate];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
     [request setSortDescriptors:@[sortDescriptor]];
     NSError* error = nil;
     NSArray* news = [mainContext executeFetchRequest:request error:&error];
     if (error) {
         NSLog(@"Error occured while fetching: %@", error);
     }
     NSLog(@"return Favorites %@", news);
     return news;
}

#pragma mark - utils

- (NSManagedObjectContext*)privateContext {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentStoreCoordinator;
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    return context;
}

- (NSManagedObject *)objectWithID:(NSString *)ID entity:(NSString *)entityName context:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identificator == %@", ID];
    [fetchRequest setPredicate:predicate];
    NSError *fetchingError = nil;
    NSArray *fetchingObjects = [context executeFetchRequest:fetchRequest error:&fetchingError];
    if (fetchingObjects == nil) {
        NSLog(@"Error occured while fetching: %@", fetchingError);
    }
    for (NSManagedObject *object in fetchingObjects) {
        return [context objectWithID:object.objectID];
    }
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    [object setValue:ID forKey:@"identificator"];
    return object;
}

- (NSPredicate *)prepareFilterPredicateForOptions:(NSDictionary *)options {
    NSMutableString *predicateFormat = [[NSMutableString alloc] init];
    
    NSMutableArray *predicates = [[NSMutableArray alloc] init];
    if (options[FILTER_START_DATE]) {
        [predicates addObject:[NSPredicate predicateWithFormat:
                               @"pubDate >= %@ AND pubDate <= %@", options[FILTER_START_DATE], options[FILTER_END_DATE]]];
    }

    if (options[FILTER_TEXT]) {
        NSString *text = options[FILTER_TEXT];
        [predicates addObject:[NSPredicate predicateWithFormat:
                               @"title CONTAINS[cd] %@ OR text CONTAINS[cd] %@", text, text]];
    }
    
    if (options[FILTER_CATEGORY]) {
        NSSet *categories = options[FILTER_CATEGORY];
      //  if (options[FILTER_DATE] || options[FILTER_TEXT]) [predicateFormat appendString:@" && "];

        NSMutableArray *orPredicates = [[NSMutableArray alloc] init];
        for (NSString *category in categories) {
    /*        [predicateFormat appendString:[NSString stringWithFormat:
                                               @"channelTitle == %@ || ",
                                               category]];*/
            [orPredicates addObject:[NSPredicate predicateWithFormat:
                                   @"channelTitle == %@", category]];
        }
        [predicates addObject:[NSCompoundPredicate orPredicateWithSubpredicates:orPredicates]];
    }
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:[predicates copy]];
}

- (NSDate *)startOfDay:(NSDate *)targetDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:targetDate];

    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];

    return [calendar dateFromComponents:dateComponents];
}

- (NSDate *)endOfDay:(NSDate *)targetDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:targetDate];

    [dateComponents setHour:23];
    [dateComponents setMinute:59];
    [dateComponents setSecond:59];

    return [calendar dateFromComponents:dateComponents];
}



@end
