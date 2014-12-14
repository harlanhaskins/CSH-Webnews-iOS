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
    
    if (!AuthenticationManager.apiKey) return;
    
    NSDictionary *tokenParameters = @{@"token" : token,
                                      @"deviceType" : @"ios",
                                      @"apiKey" : AuthenticationManager.apiKey};
    
    NSString *url = @"http://san.csh.rit.edu:38382/token";
    
    [[AFHTTPSessionManager manager] POST:url
                              parameters:tokenParameters
                                 success:nil
                                 failure:nil];
}

@end
