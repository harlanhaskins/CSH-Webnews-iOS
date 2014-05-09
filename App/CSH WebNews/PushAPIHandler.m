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

@end
