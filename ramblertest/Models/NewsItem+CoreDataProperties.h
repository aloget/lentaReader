//
//  NewsItem+CoreDataProperties.h
//  ramblertest
//
//  Created by Anna on 27/11/19.
//  Copyright © 2019 aloget. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NewsItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewsItem (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSString *imageUrl;
@property (nullable, nonatomic, retain) NSString *channelTitle;
@property (nullable, nonatomic, retain) NSString *identificator;
@property (nullable, nonatomic, retain) NSDate *pubDate;
@property (nullable, nonatomic, retain) NSNumber *isFavorite;

@end

NS_ASSUME_NONNULL_END
