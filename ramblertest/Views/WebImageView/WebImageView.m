//
//  WebImageView.m
//  smartscrolling
//
//  Created by Anna on 02/05/16.
//  Copyright © 2019 aloget. All rights reserved.
//

#import "WebImageView.h"
#import "NetworkManager.h"
#import <QuartzCore/QuartzCore.h>

@interface WebImageView() {
    NSURL* _imageUrl;
}

@end

@implementation WebImageView

- (void)setImageWithURL:(NSURL*)imageURL {
    _imageUrl = imageURL;
    [[NetworkManager sharedInstance] downloadURL:_imageUrl caching:YES completionHandler:^(NSData *data, NSError *error, BOOL cached) {
        if (error) {
            
        } else {
            UIImage* image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self setImage:image animated:!cached];
            });
        }
    }];
}

- (BOOL)isDownloadingImage {
    return [[NetworkManager sharedInstance] isDownloadingURL:_imageUrl];
}

- (void)cancelDownloadingImage {
    [[NetworkManager sharedInstance] cancelDownloadingURL:_imageUrl];
}

- (void)setImage:(UIImage*)image animated:(BOOL)animated {
    self.image = image;
    if (animated) {
        CATransition *transition = [CATransition animation];
        transition.duration = 1.0f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [self.layer addAnimation:transition forKey:nil];
    }
}
@end
