//
//  PushAPIHandler.m
//  CSH News
//
//  Created by Harlan Haskins on 3/27/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "PushAPIHandler.h"
#import "PDKeychainBindings.h"

@implementation PushAPIHandler

+ (void) sendPushToken:(NSString*)token {
    NSString *apiKey = [[PDKeychainBindings sharedKeychainBindings] objectForKey:kApiKeyKey];
    NSDictionary *tokenParameters = @{@"token" : token,
                                      @"deviceType" : @"ios",
                                      @"apiKey" : apiKey};
    
    NSString *url = @"http://san.csh.rit.edu:38382/token";
    
    [[AFHTTPSessionManager manager] POST:url parameters:tokenParameters success:nil failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    }];
}

@end
