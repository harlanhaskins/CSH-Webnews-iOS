//
//  NewsgroupTableViewModel.m
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "NewsgroupTableViewModel.h"
#import "Newsgroup.h"
#import "WebNewsDataHandler.h"
#import "CacheManager.h"

@interface NewsgroupTableViewModel ()

@property (nonatomic, readwrite) NSArray* newsgroups;

@end

@implementation NewsgroupTableViewModel

+ (instancetype) new {
    NewsgroupTableViewModel *model = [[NewsgroupTableViewModel alloc] init];
    model.newsgroups = [CacheManager cachedNewsgroups];
    return model;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.newsgroups count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Newsgroup *newsgroup = self.newsgroups[indexPath.row];
    NewsgroupCell *cell = [NewsgroupCell cellWithNewsgroup:newsgroup];
    return cell;
}

- (NSArray*) newsgroupArrayFromDictionaryArray:(NSArray*)array {
    NSMutableArray *newsgroupsArray = [NSMutableArray array];
    
    for (NSDictionary* dictionary in array) {
        Newsgroup *newsgroup = [Newsgroup newsgroupWithDictionary:dictionary];
        [newsgroupsArray addObject:newsgroup];
    }
    
    return newsgroupsArray;
}

- (void) setNewsgroups:(NSArray *)newsgroups {
    _newsgroups = newsgroups;
    [CacheManager cacheNewsgroups:newsgroups];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
