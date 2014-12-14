//
//  WebNewsDataHandler.m
//  CSH News
//
//  Created by Harlan Haskins on 12/30/13.
//  Copyright (c) 2013 CSH. All rights reserved.
//

#import "WebNewsDataHandler.h"

@implementation WebNewsDataHandler

+ (instancetype) sharedHandler {
    static WebNewsDataHandler *_sharedHandler;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        _sharedHandler = [self new];
    });
    return _sharedHandler;
}

- (id) init {
    if (self = [super init]) {
        self.securityPolicy.allowInvalidCertificates = YES;
        
        // Create a response serializer. That'll convert the JSON to an NSDictionary automagically (read: so I don't have to.)
        AFJSONResponseSerializer *serializer = (AFJSONResponseSerializer*)self.responseSerializer;
        serializer.readingOptions = (NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves);
        serializer.removesKeysWithNullValues = YES;
        
        self.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithArray:@[@"GET", @"HEAD", @"DELETE", @"PUT"]];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    }
    return self;
}

- (NSURLSessionDataTask*) GET:(NSString *)URLString parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id response))success
                      failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    parameters = [self authenticatedParameters:parameters];
    return [super GET:URLString parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask*) POST:(NSString *)URLString parameters:(id)parameters
                       success:(void (^)(NSURLSessionDataTask *task, id response))success
                       failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    parameters = [self authenticatedParameters:parameters];
    return [super POST:URLString parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask*) PUT:(NSString *)URLString parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id response))success
                      failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    parameters = [self authenticatedParameters:parameters];
    return [super PUT:URLString parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask*) DELETE:(NSString *)URLString parameters:(id)parameters
                         success:(void (^)(NSURLSessionDataTask *task, id response))success
                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    parameters = [self authenticatedParameters:parameters];
    return [super DELETE:URLString parameters:parameters success:success failure:failure];
}

- (NSDictionary*) authenticatedParameters:(NSDictionary*)parameters {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:parameters];
    dictionary[@"api_key"] = AuthenticationManager.apiKey ?: @"NULL_API_KEY";
    dictionary[@"api_agent"] = @"iOS";
    return dictionary;
}

- (NSURL*) baseURL {
    return [NSURL URLWithString:@"https://webnews.csh.rit.edu"];
}

@end
