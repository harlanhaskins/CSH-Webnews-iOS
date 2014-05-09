//
//  PushAPIHandler.h
//  CSH News
//
//  Created by Harlan Haskins on 3/27/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebNewsDataHandler.h"

@interface PushAPIHandler : NSObject

+ (void) sendPushToken:(NSString*)token;
@end
