//
//  NetworkManager.m
//  smartscrolling
//
//  Created by Anna on 03/05/16.
//  Copyright © 2019 aloget. All rights reserved.
//

#import "NetworkManager.h"

const NSUInteger CASH_SIZE = 250 * 1024 * 1024;
const NSUInteger CASH_DISK_SIZE = 250 * 1024 * 1024;

@interface NetworkManager() {
    NSURLSession* _session;
    NSURLSession* _noCacheSession;
    NSMutableDictionary* _tasks;
}

@end

@implementation NetworkManager

+ (NetworkManager*)sharedInstance {
    
    static NetworkManager* instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _tasks = [[NSMutableDictionary alloc] init];
        [self setSession];
        [self setNoCacheSession];
        [self setCache];
    }
    return self;
}


- (void)downloadURL:(NSURL*)url caching:(BOOL)caching completionHandler:(void(^)(NSData* data, NSError* error, BOOL cached))completionHandler {
    NSURLRequest* request = [NSURLRequest requestWithURL:url];

    if (caching) {
        NSData* cachedData = [self cachedDataForRequest:request];
        if (cachedData) {
            completionHandler(cachedData, nil, YES);
            return;
        }
    }
    
    NSURLSession* session = caching? _session : _noCacheSession;
    
    [self downloadRequest:request usingSession:session andCompletionHandler:completionHandler];
}

- (BOOL)isDownloadingURL:(NSURL*)url {
    NSURLSessionDataTask* task = [_tasks objectForKey:url];
    return (task != nil);
}

- (void)cancelDownloadingURL:(NSURL*)url {
    NSURLSessionDataTask* task = [_tasks objectForKey:url];
    if (task) {
        [task cancel];
        [_tasks removeObjectForKey:url];
    }
}

- (void)downloadRequest:(NSURLRequest*)request usingSession:(NSURLSession*)session andCompletionHandler:(void(^)(NSData* data, NSError* error, BOOL cached))completionHandler {
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                      if (task.state != NSURLSessionTaskStateSuspended && task.state != NSURLSessionTaskStateCanceling) {
                                          completionHandler(data, error, NO);
                                          [_tasks removeObjectForKey:request.URL];
                                      }
                                  }];
    [_tasks setObject:task forKey:request.URL];
    [task resume];
}

#pragma mark - Config

- (void)setSession {
    _session = [NSURLSession sharedSession];
}

- (void)setNoCacheSession {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    _noCacheSession = [NSURLSession sessionWithConfiguration:configuration];
}

- (void)setCache {
    NSURLCache *imageCache = [[NSURLCache alloc] initWithMemoryCapacity:CASH_SIZE diskCapacity:CASH_DISK_SIZE diskPath:@"imageCache"];
    [NSURLCache setSharedURLCache:imageCache];
}



#pragma mark - Utils

- (NSData*)cachedDataForRequest:(NSURLRequest*)request {
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    return cachedResponse.data;
}


@end
