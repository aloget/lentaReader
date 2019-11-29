//
//  FeedCell.h
//  ramblertest
//
//  Created by Anna on 27/11/19.
//  Copyright © 2019 aloget. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FeedCellDelegate;

@interface FeedCell : UITableViewCell

@property (nonatomic, weak) id <FeedCellDelegate> delegate;

- (void)configureWithTitle:(NSString*)title channelTitle:(NSString*)channelTitle date:(NSDate *)date imageUrl:(NSURL*)imageUrl description:(NSString*)descriptionText favorite:(BOOL)isFavorite expanding:(BOOL)expanding;
- (void)clearExpansion;
- (BOOL)isExpanded;
- (void)expand;
- (void)collapse;

@end

@protocol FeedCellDelegate <NSObject>

- (void)favoriteButtonTappedForCell:(FeedCell *)cell withFavorite:(BOOL)isFavorite;
- (void)facebookButtonTappedForCell:(FeedCell *)cell;
- (void)vkontakteButtonTappedForCell:(FeedCell *)cell;
- (void)twitterButtonTappedForCell:(FeedCell *)cell;
- (void)readMoreButtonTappedForCell:(FeedCell *)cell;

@end
