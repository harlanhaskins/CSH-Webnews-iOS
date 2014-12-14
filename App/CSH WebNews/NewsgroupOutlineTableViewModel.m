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

@end

@implementation NewsgroupOutlineTableViewModel

+ (instancetype) new {
    NewsgroupOutlineTableViewModel *model = [[NewsgroupOutlineTableViewModel alloc] init];
    model.newsgroups = [CacheManager cachedNewsgroupList];
    return model;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rows = self.newsgroups.count;
    [tableView addLoadingTextIfNecessaryForRows:rows withItemName:@"Newsgroups"];
    return rows;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsgroupOutline *newsgroup = self.newsgroups[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsgroupCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [newsgroup textWithUnreadCount];
    
    if (newsgroup.unreadPosts > 0) {
        cell.textLabel.textColor = [Post colorForPersonalClass:newsgroup.highestPriorityPersonalClass];
    }
    else {
        cell.textLabel.textColor = [Post colorForPersonalClass:PersonalClassDefault];
    }
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
        if (block) {
           block();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error downloading data. Please check your internet connection." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alert show];
    }];
}

@end
