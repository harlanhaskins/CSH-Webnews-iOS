//
//  NewsgroupTableViewModel.m
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "NewsgroupOutlineTableViewModel.h"
#import "NewsgroupThreadsViewController.h"
#import "NewsgroupOutline.h"
#import "WebNewsDataHandler.h"
#import "CacheManager.h"
#import "NewsgroupThread.h"

@interface NewsgroupOutlineTableViewModel ()

@property (nonatomic, readwrite) NSArray* newsgroups;

@end

@implementation NewsgroupOutlineTableViewModel

+ (instancetype) new {
    NewsgroupOutlineTableViewModel *model = [[NewsgroupOutlineTableViewModel alloc] init];
    model.newsgroups = [CacheManager cachedNewsgroupList];
    return model;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.newsgroups count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsgroupOutline *newsgroup = self.newsgroups[indexPath.row];
    NewsgroupOutlineCell *cell = [NewsgroupOutlineCell cellWithNewsgroup:newsgroup];
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

- (void) setNewsgroups:(NSArray *)newsgroups {
    _newsgroups = newsgroups;
    [CacheManager cacheNewsgroupList:newsgroups];
}

- (void) loadDataWithBlock:(void(^)())block {
    
    NSString *parameters = @"newsgroups";
    
    [WebNewsDataHandler runHTTPOperationWithParameters:parameters success:^(AFHTTPRequestOperation *op, id response) {
        NSArray *newsgroups = [self newsgroupArrayFromDictionaryArray:response[parameters]];
        [self setNewsgroups:newsgroups];
        block();
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error downloading data. Please check your internet connection." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alert show];
    }];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self loadNewsgroupIndexWithNewsgroup:self.newsgroups[indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) loadNewsgroupIndexWithNewsgroup:(NewsgroupOutline*)newsgroup {
    NewsgroupThreadsViewController *threadsVC = [NewsgroupThreadsViewController threadListWithNewsgroupOutline:newsgroup];
    self.pushViewControllerBlock(threadsVC);
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
