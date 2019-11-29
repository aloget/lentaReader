//
//  WebImageView.h
//  smartscrolling
//
//  Created by Anna on 02/05/16.
//  Copyright © 2019 aloget. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebImageView : UIImageView

- (void)setImageWithURL:(NSURL*)imageURL;
- (BOOL)isDownloadingImage;
- (void)cancelDownloadingImage;
- (void)setImage:(UIImage*)image animated:(BOOL)animated;

@end
