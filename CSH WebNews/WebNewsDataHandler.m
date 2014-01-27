//
//  BryxHTTPHandler.m
//  Bryx 911
//
//  Created by Harlan Haskins on 12/30/13.
//  Copyright (c) 2013 Bryx. All rights reserved.
//

#import "WebNewsDataHandler.h"

@implementation WebNewsDataHandler

+ (void) runHTTPOperationWithURL:(NSURL*)url success:(HTTPSuccessBlock)successBlock failure:(HTTPFailureBlock)failure {
    
    // Create an NSURLRequest with that URL.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    // Create an AFHTTPRequestOperation with that request. Lots of creation here.
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    // Necessary because CSH is stingy with their SSL.
    operation.securityPolicy.allowInvalidCertificates = YES;
    
    // Create a response serializer. That'll convert the JSON to an NSDictionary automagically (read: so I don't have to.)
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializerWithReadingOptions:(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves)];
    
    operation.responseSerializer = serializer;
    [operation setCompletionBlockWithSuccess:successBlock failure:failure];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

@end
