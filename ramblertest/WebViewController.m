//
//  WebViewController.m
//  ramblertest
//
//  Created by Анна on 28.11.2019.
//  Copyright © 2019 aloget. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

@interface WebViewController ()

@property (strong, nonatomic) WKWebView *webView;
@property NSURL *url;

@end

@implementation WebViewController

-(instancetype)initWithUrl:(NSURL *)url {
    self = [super init];
    if (self) {
        _url = url;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    CGRect frame = self.view.frame;
    frame.origin.y = frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    _webView = [[WKWebView alloc] initWithFrame:frame];
    [self.view addSubview:_webView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURLRequest *request = [NSURLRequest requestWithURL:_url];
    [_webView loadRequest:request];
}

- (void)loadURL:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
