//
//  CacheManager.h
//  CSH News
//
//  Created by Harlan Haskins on 1/27/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheManager : NSObject

+ (NSArray*) cachedActivity;
+ (void) cacheActivityThreads:(NSArray*)array;

@end
