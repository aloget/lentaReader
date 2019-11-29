//
//  NewsItem+CoreDataProperties.m
//  ramblertest
//
//  Created by Anna on 27/11/19.
//  Copyright © 2019 aloget. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NewsItem+CoreDataProperties.h"

@implementation NewsItem (CoreDataProperties)

@dynamic title;
@dynamic text;
@dynamic imageUrl;
@dynamic channelTitle;
@dynamic identificator;
@dynamic pubDate;
@dynamic isFavorite;

@end
