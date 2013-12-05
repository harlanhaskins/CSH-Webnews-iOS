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


- (NSDictionary*) webNewsDataForViewController:(id<WebNewsDataHandlerProtocol>)viewController {
    
    NSString *apiKey = [[PDKeychainBindings sharedKeychainBindings] objectForKey:kApiKeyKey];
    
    NSDictionary *parameters = @{kApiKeyKey:apiKey, @"api_agent":@"iOS"};
    
    if ([viewController respondsToSelector:@selector(specialParameters)]) {
        parameters = [parameters dictionaryByMergingWith:[viewController performSelector:@selector(specialParameters)]];
    }
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    [client setAllowsInvalidSSLCertificate:YES];
    client.defaultSSLPinningMode = AFSSLPinningModeNone;
    
    __block NSDictionary *data;
    __block NSError *blockError;
    
    NSString *path;
    
    if ([viewController respondsToSelector:@selector(pathString)]) {
        path = [viewController performSelector:@selector(pathString)];
    }
    else {
        path = viewController.title.lowercaseString;
    }
    
    [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    [client getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        data = responseObject;
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
    [MBProgressHUD hideAllHUDsForView:viewController.view animated:YES];
    
    return data;
}

- (NSDictionary*) webNewsDataWithCustomURLPath:(NSString*)path {
    
    NSString *apiKey = [[PDKeychainBindings sharedKeychainBindings] objectForKey:kApiKeyKey];
    
    NSDictionary *parameters = @{kApiKeyKey:apiKey, @"api_agent":@"iOS"};
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    [client setAllowsInvalidSSLCertificate:YES];
    client.defaultSSLPinningMode = AFSSLPinningModeNone;
    
    __block NSDictionary *data;
    __block NSError *blockError;
    
    [client getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        data = responseObject;
        NSLog(@"Loaded Data: %@", data);
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
    return data;
}

@end
