//
//  WebViewController.h
//  ramblertest
//
//  Created by Анна on 28.11.2019.
//  Copyright © 2019 aloget. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebViewController : UIViewController

-(void)loadURL:(NSURL *)url;
-(instancetype)initWithUrl:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
