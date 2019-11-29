//
//  FeedViewController.m
//  ramblertest
//
//  Created by Anna on 27/11/19.
//  Copyright © 2019 aloget. All rights reserved.
//

#import "FeedViewController.h"
#import "NewsAPI.h"
#import "NewsItem.h"
#import "FeedCell.h"
#import "WebViewController.h"
#import "DataManager.h"
#import "FilterViewController.h"

typedef enum {
    SocialMediaFacebook,
    SocialMediaVkontakte,
    SocialMediaTwitter,
} SocialMedia;

@interface FeedViewController () <FeedCellDelegate, FilterViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* news;
@property (strong, nonatomic) NSMutableArray* expandedIndexPaths;
@property (weak) FeedCell *currentExpanded;
@property BOOL isFavoriteController;
@property NSDictionary *filterOptions;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFavoriteController = [self.title isEqualToString:@"Избранное"];
    _expandedIndexPaths = [[NSMutableArray alloc] init];
    
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 130.0;
    
    if (self.isFavoriteController) {
        [self reloadFavorites];
    } else {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.tableView.refreshControl = refreshControl;
        [refreshControl addTarget:self action:@selector(reloadData:) forControlEvents:UIControlEventValueChanged];
        [self reloadData:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData:(id)sender {
    _news = [[NewsAPI sharedInstance] getNews];
    [[NewsAPI sharedInstance] loadNewsWithCompletionHandler:^{
        _news = [[NewsAPI sharedInstance] getNews];
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView.refreshControl endRefreshing];
    }];
}

- (void)reloadFavorites {
    _news = [[DataManager sharedInstance] getFavorites];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _news.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedCell* newCell = [tableView dequeueReusableCellWithIdentifier:@"feedCell" forIndexPath:indexPath];
    NewsItem* newsItem = [_news objectAtIndex:indexPath.row];
    [newCell configureWithTitle:newsItem.title channelTitle:newsItem.channelTitle date:newsItem.pubDate imageUrl:[NSURL URLWithString:newsItem.imageUrl] description:newsItem.text favorite:newsItem.isFavorite.boolValue expanding:NO];
    newCell.delegate = self;
    return newCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedCell* selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if ([selectedCell isExpanded]) {
    //    [_expandedIndexPaths removeObject:indexPath];
        [selectedCell collapse];
        _currentExpanded = nil;
    } else {
   //     [_expandedIndexPaths addObject:indexPath];
        [selectedCell expand];
        if (_currentExpanded) {
            [_currentExpanded collapse];
        }
        _currentExpanded = selectedCell;
    }
    [tableView beginUpdates];
    [tableView endUpdates];
}

#pragma mark - FeedCellDelegate


- (void)favoriteButtonTappedForCell:(FeedCell *)cell withFavorite:(BOOL)isFavorite {
    NSLog(@"Favorite!");
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NewsItem *news = [self.news objectAtIndex:indexPath.row];
    [[DataManager sharedInstance] setFavorite:isFavorite forNews:news withCompletionHandler:^{

       NSString *actionString = isFavorite ? @"Добавлено в избранное!" : @"Удалено из избранного...";
       UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ура"
                                   message:actionString
                                   preferredStyle:UIAlertControllerStyleAlert];
        
        
        if (!self.isFavoriteController) {
            UIAlertAction* goToFavoritesAction = [UIAlertAction actionWithTitle:@"В избранное" style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                [self dismissViewControllerAnimated:YES completion:^{
                    [self performSegueWithIdentifier:@"showFavorites" sender:nil];
                }];
            }];
            [alert addAction:goToFavoritesAction];
        }

        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Отлично" style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];

    
        [self presentViewController:alert animated:YES completion:^{
            if (self.isFavoriteController) {
                [self reloadFavorites];
            }
        }];
    }];
}

- (NSString *)shareStringForNews:(NewsItem *)news forSocial:(SocialMedia)socialMedia{
    switch (socialMedia) {
        case SocialMediaFacebook:
            return [NSString stringWithFormat:@"http://www.facebook.com/sharer.php?s=100&p[title]=%@&p[summary]=%@&p[url]=%@&p[images][0]=%@",
                  news.title,
                  news.text,
                  news.identificator,
                  news.imageUrl];
            break;
        case SocialMediaVkontakte:
            return [NSString stringWithFormat:@"http://vkontakte.ru/share.php?url=%@&title=%@&description=%@&image=%@&noparse=true",
                  news.identificator,
                  news.title,
                  news.text,
                  news.imageUrl];
            break;
        case SocialMediaTwitter:
            return [NSString stringWithFormat:@"http://twitter.com/share?text=%@&url=%@&counturl=%@",
                    news.title,
                    news.identificator,
                    news.identificator];
            break;
            
        default:
            break;
    }
    return @"";
}

- (void)showShareDialogForCell:(FeedCell *)cell socialMedia:(SocialMedia)socialMedia {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NewsItem *news = [self.news objectAtIndex:indexPath.row];
    NSString *shareString = [self shareStringForNews:news forSocial:socialMedia];
    NSString *encoded = [shareString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSURL *url = [NSURL URLWithString:encoded];
    WebViewController *wvc = [[WebViewController alloc] initWithUrl:url];
    [self.navigationController presentViewController:wvc animated:YES completion:nil];
}

- (void)facebookButtonTappedForCell:(FeedCell *)cell {
    [self showShareDialogForCell:cell socialMedia:SocialMediaFacebook];
}

- (void)vkontakteButtonTappedForCell:(FeedCell *)cell {
    [self showShareDialogForCell:cell socialMedia:SocialMediaVkontakte];
}
- (void)twitterButtonTappedForCell:(FeedCell *)cell{
    [self showShareDialogForCell:cell socialMedia:SocialMediaTwitter];
}

- (void)readMoreButtonTappedForCell:(FeedCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NewsItem *news = [self.news objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:news.identificator];
    WebViewController *wvc = [[WebViewController alloc] initWithUrl:url];
    [self.navigationController pushViewController:wvc animated:YES];
}

- (IBAction)filterButtonTapped:(id)sender {
    
}

#pragma mark - FilterViewDelegate

- (void)preparedFilterWithOptions:(NSDictionary *)filterOptions viewController:(FilterViewController *)viewController {
    NSLog(@"Delegated Opts: %@", filterOptions);
    _filterOptions = filterOptions;
    _news = [[DataManager sharedInstance] getNewsWithOptions:filterOptions];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"showFilter"]) {
        FilterViewController *filterViewController = [segue destinationViewController];
        filterViewController.delegate = self;
        if (_filterOptions) {
            NSLog(@"Ready opts: %@", _filterOptions);
            [filterViewController setOptions:_filterOptions];
        }
    }
}


@end
