//
//  ActivityTableViewModel.m
//  CSH News
//
//  Created by Harlan Haskins on 1/27/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "ActivityTableViewModel.h"
#import "WebNewsDataHandler.h"
#import "ActivityThread.h"
#import "CacheManager.h"
#import "CSH_News-Swift.h"

@interface ActivityTableViewModel ()

@end

@implementation ActivityTableViewModel

+ (instancetype) new {
    ActivityTableViewModel *model = [[ActivityTableViewModel alloc] init];
    model.threads = [CacheManager cachedActivity];
    return model;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rows = self.threads.count;
    [tableView addLoadingTextIfNecessaryForRows:rows withItemName:@"Threads"];
    return rows;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ThreadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThreadCell"
                                                       forIndexPath:indexPath];
    ActivityThread *thread = self.threads[indexPath.row];
    [cell setThread:thread indexPath:indexPath];
    return cell;
}

- (NSArray*) activityThreadArrayFromDictionaryArray:(NSArray*)array {
    NSMutableArray *activityThreads = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        ActivityThread *thread = [ActivityThread activityThreadWithDictionary:dict];
        [activityThreads addObject:thread];
    }
    return activityThreads;
}

- (void) setThreads:(NSArray *)threads {
    _threads = threads;
    [CacheManager cacheActivityThreads:self.threads];
}

- (void) loadDataWithBlock:(void(^)())block invalidAPIKeyBlock:(void (^)(NSError *error))failure {
    
    NSString *url = @"activity";
    
    [[WebNewsDataHandler sharedHandler] GET:url parameters:nil success:^(NSURLSessionDataTask *task, id response) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            NSArray *activityThreads = [self activityThreadArrayFromDictionaryArray:response[url]];
            [self setThreads:activityThreads];
            dispatch_async(dispatch_get_main_queue(), block);
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

@end
