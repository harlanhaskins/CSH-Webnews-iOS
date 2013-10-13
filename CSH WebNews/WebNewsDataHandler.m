//
//  WebNewsDataHandler.m
//  CSH WebNews
//
//  Created by Harlan Haskins on 9/19/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import "WebNewsDataHandler.h"
#import "BoardViewController.h"

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


- (NSArray*) webNewsDataForViewController:(id<WebNewsDataHandlerProtocol>)viewController {
    
    NSString *apiKey = [[PDKeychainBindings sharedKeychainBindings] objectForKey:kApiKeyKey];
    
    NSDictionary *parameters = @{kApiKeyKey:apiKey, @"api_agent":@"iOS"};
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    [client setAllowsInvalidSSLCertificate:YES];
    client.defaultSSLPinningMode = AFSSLPinningModeNone;
    
    __block NSArray *data;
    __block NSError *blockError;
    
    NSString *path = viewController.title.lowercaseString;
    
    if ([viewController respondsToSelector:@selector(pathString)]) {
        path = [viewController performSelector:@selector(pathString)];
    }
    [client getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        data = responseObject[path];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        blockError = error;
        NSLog(@"Error: %@", error);
    }];
    NSDate *currentDate = [NSDate date];
    while ((!data && !blockError)) {
        if ([[NSDate date] timeIntervalSinceDate:currentDate] >= 15) {
            return nil;
        }
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
    NSLog(@"Loaded Data.");
    return data;
}

@end
