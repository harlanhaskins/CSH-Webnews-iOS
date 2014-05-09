//
//  CacheManager.h
//  CSH News
//
//  Created by Harlan Haskins on 1/27/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Post, NewsgroupOutline;

@interface CacheManager : NSObject

+ (NSArray*) cachedActivity;
+ (void) cacheActivityThreads:(NSArray*)array;
+ (void) cacheNewsgroupList:(NSArray*)array;
+ (NSArray*) cachedNewsgroupList;
+ (Post*) cachedPostWithNewsgroup:(NSString*)newsgroup number:(NSInteger)postNumber;
+ (void) cachePosts:(NSArray*)array;
+ (void) cachePost:(Post*)post;
+ (NSArray*) cachedThreadsWithOutline:(NewsgroupOutline*)outline;
+ (void) cacheThreads:(NSArray*)array withOutline:(NewsgroupOutline*)outline;
+ (void) clearAllCaches;

@end
