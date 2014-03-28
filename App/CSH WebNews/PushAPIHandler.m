//
//  PushAPIHandler.m
//  CSH News
//
//  Created by Harlan Haskins on 3/27/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "PushAPIHandler.h"

@implementation PushAPIHandler

+ (void) sendPushToken:(NSString*)token withSuccess:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *tokenParameters = [NSString stringWithFormat:@"?token=%@&deviceType=ios", token];
    NSURL *url = [self urlFromParameters:tokenParameters];
    
    if (!url) {
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [[AFJSONResponseSerializer alloc] init];
    op.securityPolicy.allowInvalidCertificates = YES;
    [op setCompletionBlockWithSuccess:success failure:failure];
    
    [[NSOperationQueue mainQueue] addOperation:op];
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
