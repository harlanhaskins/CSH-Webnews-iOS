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
    
    NSString *cellID = @"NewsgroupCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:cellID];
    }
    
    
    cell.textLabel.text = [newsgroup textWithUnreadCount];
    
    if (newsgroup.unreadPosts > 0) {
        cell.textLabel.textColor = [Post colorForPersonalClass:newsgroup.highestPriorityPersonalClass];
    }
    
    cell.textLabel.font = [newsgroup fontForName];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.backgroundColor =
    cell.detailTextLabel.backgroundColor =
    cell.backgroundColor = [UIColor whiteColor];
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
    
    NSString *url = @"newsgroups";
    
    [[WebNewsDataHandler sharedHandler] GET:url parameters:nil success:^(NSURLSessionDataTask *task, id response) {
        NSArray *newsgroups = [self newsgroupArrayFromDictionaryArray:response[url]];
        [self setNewsgroups:newsgroups];
        block();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
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

@end
