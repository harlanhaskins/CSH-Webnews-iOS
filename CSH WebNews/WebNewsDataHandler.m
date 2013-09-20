//
//  WebNewsDataHandler.m
//  CSH WebNews
//
//  Created by Harlan Haskins on 9/19/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import "WebNewsDataHandler.h"

@implementation WebNewsDataHandler

@synthesize baseURL;

- (instancetype) init {
    if (self = [super init]) {
        baseURL = @"https://webnews.csh.rit.edu/";
    }
    return self;
}

+ (instancetype) sharedHandler {
    static WebNewsDataHandler *dataHandler;
    
    if (!dataHandler) {
        dataHandler = [[self class] new];
    }
    
    return dataHandler;
}


- (NSArray*) webNewsDataForPath:(NSString*)path {
    NSString *apiKey = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"api_key"];
    NSDictionary *parameters = @{@"api_key":apiKey, @"api_agent":@"iOS"};
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    [client setAllowsInvalidSSLCertificate:YES];
    client.defaultSSLPinningMode = AFSSLPinningModeNone;
    
    __block NSArray *threads;
    
    [client getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        threads = responseObject[path];
        NSLog(@"%@", threads);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    while (!threads) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
    return threads;
}

@end
