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
    NSString *tokenParameters = [NSString stringWithFormat:@"&token=%@", token];
    [self runHTTPPOSTOperationWithBaseURL:@"token" parameters:tokenParameters success:success failure:failure];
}

+ (NSURL*) urlFromParameters:(NSString*)parameters {
    NSString *baseURL = @"https://harlanhaskins.com/";
    
    NSString *apiKey = [[PDKeychainBindings sharedKeychainBindings] objectForKey:kApiKeyKey];
    
    NSString *apiKeyString = [NSString stringWithFormat:@"api_key=%@", apiKey];
    
    NSString *questionMarkString = @"?";
    NSString *ampersandString = @"&";
    
    if ([parameters rangeOfString:questionMarkString].location == NSNotFound) {
        apiKeyString = [questionMarkString stringByAppendingString:apiKeyString];
    }
    else {
        apiKeyString = [ampersandString stringByAppendingString:apiKeyString];
    }
    
    parameters = [parameters stringByAppendingString:apiKeyString];
    
    baseURL = [baseURL stringByAppendingString:apiKeyString];
    
    return [NSURL URLWithString:baseURL];
}

@end
