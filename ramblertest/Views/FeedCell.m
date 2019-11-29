//
//  FeedCell.m
//  ramblertest
//
//  Created by Anna on 27/11/19.
//  Copyright © 2019 aloget. All rights reserved.
//

#import "FeedCell.h"
#import "WebImageView/WebImageView.h"

@interface FeedCell()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet WebImageView *webImageView;
@property (weak, nonatomic) IBOutlet UILabel *channelLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (copy, nonatomic) NSString* expansionText;
@property (strong, nonatomic) UITextView* textView;
@property (weak, nonatomic) IBOutlet UIView *toolTip;
@property (weak, nonatomic) IBOutlet UIButton *favButton;


@end

@implementation FeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _toolTip.hidden = YES;
    [_favButton setImage:[UIImage imageNamed:@"fav"] forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithTitle:(NSString*)title channelTitle:(NSString*)channelTitle date:(NSDate *)date imageUrl:(NSURL*)imageUrl description:(NSString*)descriptionText favorite:(BOOL)isFavorite expanding:(BOOL)expanding {
    NSLog(@"I am cell, my isFavorite is %d", isFavorite);
    _titleLabel.text = title;
    _channelLabel.text = channelTitle;
    _expansionText = descriptionText;
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd.MM HH:mm";
    _dateLabel.text = [formatter stringFromDate:date];
    [_favButton setSelected:isFavorite];
    [self clearExpansion];
    if (expanding) [self expand];
    [self clearImage];
    if (imageUrl) {
        [_webImageView setImageWithURL:imageUrl];
    }
}

- (void)clearImage {
    if ([self.webImageView isDownloadingImage]) {
        [self.webImageView cancelDownloadingImage];
    }
    self.webImageView.image = nil;
}

- (void)clearExpansion {
    [self collapse];
}

- (BOOL)isExpanded {
    return (_textView != nil);
}

- (void)expand {
    [self showDescription];
}

- (void)collapse {
    [self hideDescription];
}

- (void)showDescription {
    _textView = [[UITextView alloc] init];
    _textView.scrollEnabled = NO;
    _textView.editable = NO;
    [_textView setText:_expansionText];
    [_textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView addSubview:_textView];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_textView
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_webImageView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1.0
                                                                  constant:8.0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_textView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1.0
                                                                  constant:8.0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_textView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_titleLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
    NSLayoutConstraint* bottomConstraint = [NSLayoutConstraint constraintWithItem:_textView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.toolTip
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1.0
                                                                         constant:8.0];
    [bottomConstraint setPriority:999.f];
    [self.contentView addConstraint:bottomConstraint];
        
    _textView.userInteractionEnabled = NO;
    _toolTip.hidden = NO;
}


- (void)hideDescription {
    [_textView removeFromSuperview];
    _textView = nil;
    _toolTip.hidden = YES;
}

- (IBAction)fbButtonTapped:(id)sender {
    [self.delegate facebookButtonTappedForCell:self];
}

- (IBAction)vkButtonTapped:(id)sender {
    [self.delegate vkontakteButtonTappedForCell:self];
}

- (IBAction)twButtonTapped:(id)sender {
    [self.delegate twitterButtonTappedForCell:self];
}

- (IBAction)readMoreButtonTapped:(id)sender {
    [self.delegate readMoreButtonTappedForCell:self];
}

- (IBAction)favButtonTapped:(id)sender {
    UIButton *favButton = (UIButton *)sender;
    [favButton setSelected:!favButton.isSelected];
    [self.delegate favoriteButtonTappedForCell:self withFavorite:favButton.isSelected];
}

@end
