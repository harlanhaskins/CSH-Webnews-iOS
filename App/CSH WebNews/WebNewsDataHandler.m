//
//  WebNewsDataHandler.m
//  CSH News
//
//  Created by Harlan Haskins on 12/30/13.
//  Copyright (c) 2013 CSH. All rights reserved.
//

#import "WebNewsDataHandler.h"

@implementation WebNewsDataHandler

+ (void) runHTTPOperationWithRequest:(NSURLRequest*)request
                             success:(HTTPSuccessBlock)successBlock
                             failure:(HTTPFailureBlock)failure  {
    // Create an AFHTTPRequestOperation with that request. Lots of creation here.
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    // Necessary because CSH is stingy with their SSL.
    operation.securityPolicy.allowInvalidCertificates = YES;
    
    // Create a response serializer. That'll convert the JSON to an NSDictionary automagically (read: so I don't have to.)
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializerWithReadingOptions:(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves)];
    
    operation.responseSerializer = serializer;
    
    HTTPFailureBlock failureBlock = ^(AFHTTPRequestOperation *op, NSError *error) {
        NSLog(@"Error Sending Request: %s - %@", __PRETTY_FUNCTION__, error);
        if (operation.response.statusCode == 401) {
            [[PDKeychainBindings sharedKeychainBindings] setObject:@"NULL_API_KEY" forKey:kApiKeyKey];
        }
        failure(op, error);
    };
    
    [operation setCompletionBlockWithSuccess:successBlock failure:failureBlock];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

+ (void) runHTTPGETOperationWithParameters:(NSString*)parameters
                                success:(HTTPSuccessBlock)successBlock
                                failure:(HTTPFailureBlock)failure {
    
    NSURL *url = [self urlFromParameters:parameters];
    
    // Create an NSURLRequest with that URL.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"GET"];
    
    [self runHTTPOperationWithRequest:request success:successBlock failure:failure];
}

+ (NSURL *) urlFromParameters:(NSString*)parameters {
    NSString *apiKey = [[PDKeychainBindings sharedKeychainBindings] objectForKey:kApiKeyKey];
    
    NSString *apiKeyString = [NSString stringWithFormat:@"api_key=%@&api_agent=iOS", apiKey];
    
    NSString *questionMarkString = @"?";
    NSString *ampersandString = @"&";
    
    if ([parameters rangeOfString:questionMarkString].location == NSNotFound) {
        apiKeyString = [questionMarkString stringByAppendingString:apiKeyString];
    }
    else {
        apiKeyString = [ampersandString stringByAppendingString:apiKeyString];
    }
    
    parameters = [parameters stringByAppendingString:apiKeyString];
    
    NSString *activityString = [NSString stringWithFormat:kBaseURLFormat, parameters];
    
    // Need to encode this way instead of stringByAddingPercentEscapesUsingEncoding: so we can ignore the '+' in 'r+d'.
    NSString *urlString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                  (CFStringRef)activityString,
                                                                  NULL,
                                                                  (CFStringRef) @"+",
                                                                  kCFStringEncodingUTF8));
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    return url;
}

+ (void) runHTTPPUTOperationWithParameters:(NSString*)parameters
                                   success:(HTTPSuccessBlock)successBlock
                                   failure:(HTTPFailureBlock)failure {
    NSURL *url = [self urlFromParameters:parameters];
    
    // Create an NSURLRequest with that URL.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"PUT"];
    
    [self runHTTPOperationWithRequest:request success:successBlock failure:failure];
}

+ (void) runHTTPDELETEOperationWithParameters:(NSString*)parameters
                                   success:(HTTPSuccessBlock)successBlock
                                   failure:(HTTPFailureBlock)failure {
    NSURL *url = [self urlFromParameters:parameters];
    
    // Create an NSURLRequest with that URL.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"DELETE"];
    
    [self runHTTPOperationWithRequest:request success:successBlock failure:failure];
}

+ (void) runHTTPPOSTOperationWithBaseURL:(NSString*)baseURL
                              parameters:(NSString*)parameters
                                   success:(HTTPSuccessBlock)successBlock
                                   failure:(HTTPFailureBlock)failure {
    NSURL *url = [self urlFromParameters:baseURL];
    
    // Create an NSURLRequest with that URL.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:@"POST"];
    
    NSData *postData = [parameters dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:postData];
    
    [self runHTTPOperationWithRequest:request success:successBlock failure:failure];
}

@end
