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
#import "NSMutableArray+HHActionButtons.h"
#import "SVProgressHUD.h"

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
    return [self.threads count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsgroupThread *thread = self.threads[indexPath.row];
    NSString *cellID = @"NewsgroupThread";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = thread.post.subject;
    cell.textLabel.font = [thread fontForSubject];
    cell.detailTextLabel.text = [thread.post authorshipAndTimeString];
    
    cell.textLabel.textColor = thread.post.subjectColor;
    
    cell.backgroundColor =
    cell.textLabel.backgroundColor =
    cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
    
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
    NSString *date = [oldestThread.post dateString];
    [self loadDataWithParameters:@{@"limit" : @20,
                                   @"from_older" : date}];
}

- (NSArray*) arrayByMergingArray:(NSArray*)array intoArray:(NSArray*)otherArray {
    array = array ?: @[];
    otherArray = otherArray ?: @[];
    NSArray *newArray = [@[array, otherArray] valueForKeyPath: @"@distinctUnionOfArrays.self"];
    newArray = [newArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj2 compare:obj1];
    }];
    return newArray;
}

- (void) loadDataWithParameters:(NSDictionary*)parameters {
    NSString *url = [NSString stringWithFormat:@"%@/index", self.outline.name];
    
    [[WebNewsDataHandler sharedHandler] GET:url parameters:parameters success:^(NSURLSessionDataTask *task, id response) {
        NSArray *threads = [self newsgroupThreadsFromNewsgroupThreadDictionaryArray:response[@"posts_older"]];
        [self setThreads:threads];
        self.loadDataBlock();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsgroupThread *thread = self.threads[indexPath.row];
    ThreadPostsViewController *threadVC = [ThreadPostsViewController controllerWithThread:thread];
    threadVC.reloadThreadsBlock = self.loadDataBlock;
    self.pushViewControllerBlock(threadVC);
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
