//
//  NetworkManager.h
//  smartscrolling
//
//  Created by Anna on 03/05/16.
//  Copyright © 2019 aloget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

+ (NetworkManager*)sharedInstance;

- (void)downloadURL:(NSURL*)url caching:(BOOL)caching completionHandler:(void(^)(NSData* data, NSError* error, BOOL cached))completionHandler;
- (BOOL)isDownloadingURL:(NSURL*)url;
- (void)cancelDownloadingURL:(NSURL*)url;

@end
