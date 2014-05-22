//
//  BryxHTTPHandler.h
//  Bryx 911
//
//  Created by Harlan Haskins on 12/30/13.
//  Copyright (c) 2013 Bryx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface WebNewsDataHandler : AFHTTPSessionManager

+ (instancetype) sharedHandler;

@end
