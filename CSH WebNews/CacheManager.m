//
//  CacheManager.m
//  CSH News
//
//  Created by Harlan Haskins on 1/27/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "CacheManager.h"

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
