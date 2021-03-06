//
//  NewsgroupThreadTableViewController.m
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "NewsgroupThreadListTableViewModel.h"
#import "NewsgroupOutline.h"
#import "WebNewsDataHandler.h"
#import "NewsgroupThread.h"
#import "CacheManager.h"
#import "ThreadPostsViewController.h"
#import "CSH_News-Swift.h"

@interface NewsgroupThreadListTableViewModel ()

@property (nonatomic, readwrite) NewsgroupOutline *outline;
@property (nonatomic, readwrite) NSArray *threads;

@end

@implementation NewsgroupThreadListTableViewModel
 
+ (instancetype) threadListWithNewsgroupOutline:(NewsgroupOutline*)outline {
    NewsgroupThreadListTableViewModel *model = [[NewsgroupThreadListTableViewModel alloc] init];
    model.outline = outline;
    model.threads = [CacheManager cachedThreadsWithOutline:outline];
    return model;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rows = self.threads.count;
    [tableView addLoadingTextIfNecessaryForRows:rows withItemName:@"Threads"];
    return rows;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<ThreadProtocol> thread = self.threads[indexPath.row];
    
    ThreadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThreadCell" forIndexPath:indexPath];
    [cell setThread:thread indexPath:indexPath];
    
    return cell;
}

- (NSArray*) newsgroupArrayFromDictionaryArray:(NSArray*)array {
    NSMutableArray *newsgroupsArray = [NSMutableArray array];
    
    for (NSDictionary* dictionary in array) {
        NewsgroupOutline *newsgroup = [NewsgroupOutline newsgroupOutlineWithDictionary:dictionary];
        [newsgroupsArray addObject:newsgroup];
    }
    
    return newsgroupsArray;
}

- (void) setThreads:(NSArray *)threads {
    _threads = [self arrayByMergingArray:threads intoArray:_threads];
    [CacheManager cacheThreads:threads withOutline:self.outline];
}

- (void) loadData {
    return [self loadDataWithParameters:@{@"limit" : @20}];
}

- (void) loadMorePosts {
    NewsgroupThread *oldestThread = [self.threads lastObject];
    if (!oldestThread) return;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSString *date = [oldestThread.post dateString];
        [self loadDataWithParameters:@{@"limit" : @20,
                                       @"from_older" : date}];
    });
}

- (NSArray *)arrayByMergingArray:(NSArray*)array intoArray:(NSArray*)otherArray {
    array = array ?: @[];
    otherArray = otherArray ?: @[];
    NSArray *newArray = [@[array, otherArray] valueForKeyPath:@"@distinctUnionOfArrays.self"];
    newArray = [newArray sortedArrayUsingSelector:@selector(compare:)];
    return newArray;
}

- (void) loadDataWithParameters:(NSDictionary*)parameters {
    NSString *url = [NSString stringWithFormat:@"%@/index", self.outline.name];
    
    [[WebNewsDataHandler sharedHandler] GET:url
                                 parameters:parameters
                                    success:^(NSURLSessionDataTask *task, id response) {
                                        NSArray *threads = [self newsgroupThreadsFromNewsgroupThreadDictionaryArray:response[@"posts_older"]];
                                        [self setThreads:threads];
                                        dispatch_async(dispatch_get_main_queue(), self.loadDataBlock);
                                    } failure:nil];
}

- (NSArray *) newsgroupThreadsFromNewsgroupThreadDictionaryArray:(NSArray*)array {
    NSMutableArray *threadsArray = [NSMutableArray array];
    for (NSDictionary *dictionary in array) {
        NewsgroupThread *thread = [NewsgroupThread newsgroupThreadWithDictionary:dictionary];
        [threadsArray addObject:thread];
    }
    return threadsArray;
}

@end
