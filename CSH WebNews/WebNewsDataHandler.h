//
//  BryxHTTPHandler.h
//  Bryx 911
//
//  Created by Harlan Haskins on 12/30/13.
//  Copyright (c) 2013 Bryx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void (^__strong HTTPSuccessBlock)(AFHTTPRequestOperation *__strong httpOperation, __strong id responseObject);
typedef void (^__strong HTTPFailureBlock)(AFHTTPRequestOperation *__strong httpOperation, NSError *__strong error);

@interface WebNewsDataHandler : NSObject

+ (void) runHTTPOperationWithURL:(NSURL*)url success:(HTTPSuccessBlock)successBlock failure:(HTTPFailureBlock)failure;

@end
