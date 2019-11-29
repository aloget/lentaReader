//
//  FilterViewController.h
//  ramblertest
//
//  Created by Анна on 28.11.2019.
//  Copyright © 2019 aloget. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define FILTER_START_DATE @"kFilterStartDate"
#define FILTER_END_DATE @"kFilterEndDate"
#define FILTER_TEXT @"kFilterText"
#define FILTER_CATEGORY @"kFilterCategory"

#define LENTA_CATEGORY @"Lenta.ru : Новости"
#define GAZETA_CATEGORY @"Газета.Ru - Новости дня"

@protocol FilterViewDelegate;

@interface FilterViewController : UITableViewController

@property (nonatomic, weak) id <FilterViewDelegate> delegate;
- (void)setOptions:(NSDictionary *)filterOptions;

@end

@protocol FilterViewDelegate <NSObject>

-(void)preparedFilterWithOptions:(NSDictionary *)filterOptions viewController:(FilterViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
