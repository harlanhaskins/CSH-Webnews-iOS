//
//  PushAPIHandler.m
//  CSH News
//
//  Created by Harlan Haskins on 3/27/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "PushAPIHandler.h"

@implementation PushAPIHandler

+ (void) sendPushToken:(NSString*)token {
    NSDictionary *tokenParameters = @{@"token" : token,
                                      @"deviceType" : @"ios"};
    
    NSString *url = @"https://san.csh.rit.edu:5000/token";
    
    [[WebNewsDataHandler sharedHandler] POST:url parameters:tokenParameters success:nil failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    }];
}

+ (NSURL*) urlFromParameters:(NSString*)parameters {
    NSString *baseURL = @"http://localhost:5000/token";
    
    NSString *apiKey = [[PDKeychainBindings sharedKeychainBindings] objectForKey:kApiKeyKey];
    
    if ([apiKey isEqualToString:@"NULL_API_KEY"]) {
        return nil;
    }
    
    NSString *apiKeyString = [NSString stringWithFormat:@"apiKey=%@", apiKey];
    
    NSString *questionMarkString = @"?";
    NSString *ampersandString = @"&";
    
    if ([parameters rangeOfString:questionMarkString].location == NSNotFound) {
        apiKeyString = [questionMarkString stringByAppendingString:apiKeyString];
    }
    else {
        apiKeyString = [ampersandString stringByAppendingString:apiKeyString];
    }
    
    parameters = [parameters stringByAppendingString:apiKeyString];
    
    baseURL = [baseURL stringByAppendingString:parameters];
    
    return [NSURL URLWithString:baseURL];
}

@end
