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

@interface NewsgroupThreadListTableViewModel ()

@property (nonatomic, readwrite) NewsgroupOutline *outline;
@property (nonatomic, readwrite) NSArray *threads;
@property (nonatomic) NSMutableArray *cellActions;

@end

@implementation NewsgroupThreadListTableViewModel
 
+ (instancetype) threadListWithNewsgroupOutline:(NewsgroupOutline*)outline {
    NewsgroupThreadListTableViewModel *model = [[NewsgroupThreadListTableViewModel alloc] init];
    model.outline = outline;
    model.threads = [CacheManager cachedThreadsWithOutline:outline];
    model.cellActions = [NSMutableArray array];
//    [model.cellActions HH_addActionButtonWithTitle:@"Reply" target:self selector:@selector(didTapReply)];
//    [model.cellActions HH_addActionButtonWithTitle:@"Star" target:self selector:@selector(didTapStar)];
//    [model.cellActions HH_addActionButtonWithTitle:@"Mark Unread" target:self selector:@selector(didTapMarkUnread)];
    return model;
}

- (void) didTapReply {
    
}

- (void) didTapStar {
    
}

- (void) didTapMarkUnread {
    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.threads count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsgroupThread *thread = self.threads[indexPath.row];
    NewsgroupThreadCell *cell = [NewsgroupThreadCell cellWithNewsgroupThread:thread reuseIdentifier:@"Cell"];
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
    _threads = threads;
    [CacheManager cacheThreads:threads withOutline:self.outline];
}

- (void) loadData {
    NSString *parameters = [NSString stringWithFormat:@"%@/index?limit=20", self.outline.name];
    
    [WebNewsDataHandler runHTTPGETOperationWithParameters:parameters success:^(AFHTTPRequestOperation *op, id response) {
        NSArray *threads = [self newsgroupThreadsFromNewsgroupThreadDictionaryArray:response[@"posts_older"]];
        [self setThreads:threads];
        self.loadDataBlock();
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsgroupThread *thread = self.threads[indexPath.row];
//    ThreadDetailViewController *threadVC = [ThreadDetailViewController threadViewControllerWithThread:thread];
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
