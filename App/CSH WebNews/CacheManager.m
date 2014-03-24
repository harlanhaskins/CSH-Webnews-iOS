//
//  CacheManager.m
//  CSH News
//
//  Created by Harlan Haskins on 1/27/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "CacheManager.h"
#import "Post.h"
#import "NewsgroupOutline.h"

@implementation CacheManager

+ (void) cacheActivityThreads:(NSArray*)array {
    [NSKeyedArchiver archiveRootObject:array toFile:[self activityCachePath]];
}

+ (NSString*) activityCachePath {
    return [self cachePathWithPathComponent:@"Activity"];
}

+ (NSArray*) cachedActivity {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self activityCachePath]];
}

+ (void) cacheNewsgroupList:(NSArray*)array {
    [NSKeyedArchiver archiveRootObject:array toFile:[self newsgroupListCachePath]];
}

+ (NSString*) newsgroupListCachePath {
    return [self cachePathWithPathComponent:@"NewsgroupsList"];
}

+ (NSArray*) cachedThreadsWithOutline:(NewsgroupOutline*)outline {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self threadListCachePathWithOutline:outline]];
}

+ (void) cacheThreads:(NSArray*)array withOutline:(NewsgroupOutline*)outline {
    [NSKeyedArchiver archiveRootObject:array toFile:[self threadListCachePathWithOutline:outline]];
}

+ (NSString*) threadListCachePathWithOutline:(NewsgroupOutline*)outline {
    NSString *outlinePath = [NSString stringWithFormat:@"%@_list", outline.name];
    return [self cachePathWithPathComponent:outlinePath];
}

+ (NSArray*) cachedNewsgroupList {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self newsgroupListCachePath]];
}

+ (void) cachePosts:(NSArray*)array {
    [NSKeyedArchiver archiveRootObject:array toFile:[self postCachePath]];
}

+ (void) cachePost:(Post*)post {
    [NSKeyedArchiver archiveRootObject:post toFile:[self postCachePathWithNumber:post.number]];
}

+ (NSString*) postCachePath {
    return [self cachePathWithPathComponent:@"Posts"];
}

+ (NSString*) postCachePathWithNumber:(NSInteger)number {
    NSString *postCachePath = [NSString stringWithFormat:@"Post_%li", (long)number];
    return [self cachePathWithPathComponent:postCachePath];
}

+ (Post*) cachedPostWithNumber:(NSInteger)postNumber {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self postCachePathWithNumber:postNumber]];
}

+ (NSString*) cachePathWithPathComponent:(NSString*)pathComponent {
    NSString *cacheFileName = [[self cachePath] stringByAppendingPathComponent:pathComponent];
    return cacheFileName;
}

+ (NSString*) cachePath {
    NSURL *cacheURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory
                                                              inDomains:NSUserDomainMask] lastObject];
    return [cacheURL path];
}

+ (void) clearAllCaches {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    
    NSString *directory = [self cachePath];
    NSArray *fileArray = [fileManager contentsOfDirectoryAtPath:directory error:&error];
    for (NSString *filename in fileArray)  {
        [fileManager removeItemAtPath:[directory stringByAppendingPathComponent:filename] error:&error];
        
        if (error) {
            NSLog(@"Error clearing caches: %@", error);
        }
    }
}
    
@end
