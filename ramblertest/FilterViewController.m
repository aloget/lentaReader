//
//  FilterViewController.m
//  ramblertest
//
//  Created by Анна on 28.11.2019.
//  Copyright © 2019 aloget. All rights reserved.
//

#import "FilterViewController.h"

@interface FilterViewController ()

@property (weak, nonatomic) IBOutlet UITextView *filterTextView;
@property (weak, nonatomic) IBOutlet UISwitch *lentaSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *gazetaSwitch;
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;


@property NSMutableSet *categories;
@property NSDictionary *filterOptions;

@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _categories = [[NSMutableSet alloc] initWithArray:@[LENTA_CATEGORY, GAZETA_CATEGORY]];
    

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_filterOptions) {
        [self setupWithOptions:_filterOptions];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setOptions:(NSDictionary *)filterOptions {
    _filterOptions = filterOptions;
}

- (void)setupWithOptions:(NSDictionary *)options {
    if (options[FILTER_START_DATE]) {
        NSLog(@"Start date: %@, dp %@", options[FILTER_START_DATE], self.startDatePicker);
        [self.startDatePicker setDate:options[FILTER_START_DATE]];
    }
    if (options[FILTER_END_DATE]) {
        NSLog(@"End date: %@", options[FILTER_END_DATE]);
        [self.startDatePicker setDate:options[FILTER_END_DATE]];
    }

    if (options[FILTER_TEXT]) {
        NSLog(@"Text: %@", options[FILTER_TEXT]);
        [self.filterTextView setText:options[FILTER_TEXT]];
    }
       
    if (options[FILTER_CATEGORY]) {
        NSLog(@"Cats: %@", options[FILTER_CATEGORY]);
        NSSet *categories = options[FILTER_CATEGORY];
        [_lentaSwitch setOn:[categories containsObject:LENTA_CATEGORY]];
        [_gazetaSwitch setOn:[categories containsObject:GAZETA_CATEGORY]];
        _categories = [[NSMutableSet alloc] initWithSet:categories];
    }
}

- (IBAction)dateSwitchTapped:(id)sender {
    UISwitch *switchControl = (UISwitch *)sender;
    self.startDatePicker.enabled = switchControl.isOn;
    self.endDatePicker.enabled = switchControl.isOn;
}

- (void)changeStateForCategory:(NSString *)category sender:(id)sender {
    UISwitch *switchControl = (UISwitch *)sender;
    if (switchControl.isOn) {
        [_categories addObject:category];
    } else {
        [_categories removeObject:category];
    }
}

- (IBAction)lentaCategorySwitchTapped:(id)sender {
    [self changeStateForCategory:LENTA_CATEGORY sender:sender];
}

- (IBAction)gazetaCategorySwitchTapped:(id)sender {
    [self changeStateForCategory:GAZETA_CATEGORY sender:sender];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:case 2:
            return 1;
            
        default:
            break;
    }
    return 0;
}

- (void)showAlertWithTitle:(NSString *) title message:(NSString *)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ну хорошо" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)checkValues {
    if (self.startDatePicker.enabled) {
        if ([self.startDatePicker.date compare: self.endDatePicker.date] == NSOrderedDescending) {
            [self showAlertWithTitle:@"Ошибка!" message:@"Конечная дата диапазона должна быть позже стартовой."];
            return NO;
        }
    }
    if (self.categories.count == 0) {
        [self showAlertWithTitle:@"Ошибка!" message:@"Не выбрано ни одной категории."];
        return NO;
    }
    return YES;
}

- (IBAction)applyButtonTapped:(id)sender {
    NSLog(@"Applied!");
    NSMutableDictionary *filterOptions = [[NSMutableDictionary alloc] init];

    if ([self checkValues]) {
         if (self.startDatePicker.enabled) {
             [filterOptions setValue:self.startDatePicker.date forKey:FILTER_START_DATE];
             [filterOptions setValue:self.endDatePicker.date forKey:FILTER_END_DATE];
         }
         
         if (self.filterTextView.text.length > 0) {
             [filterOptions setValue:self.filterTextView.text forKey:FILTER_TEXT];
         }
         
         if (self.categories.count > 0) {
             [filterOptions setValue:self.categories forKey:FILTER_CATEGORY];
         }
         
         [self.delegate preparedFilterWithOptions:[filterOptions copy] viewController:self];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
