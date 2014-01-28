//
//  ActivityTableViewModel.m
//  CSH News
//
//  Created by Harlan Haskins on 1/27/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "ActivityTableViewModel.h"
#import "ActivityThreadCell.h"
#import "WebNewsDataHandler.h"
#import "ActivityThread.h"
#import "CacheManager.h"

@interface ActivityTableViewModel ()

@property (nonatomic, readwrite) NSArray *threads;

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
    return [self.threads count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"ActivityThreadCell_%i%i", indexPath.row, indexPath.section];
    ActivityThreadCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [ActivityThreadCell cellWithActivityThread:self.threads[indexPath.row] reuseIdentifier:cellIdentifier];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (void) loadDataWithBlock:(void(^)())block {
    
    NSString *parameters = @"activity";
    
    [WebNewsDataHandler runHTTPOperationWithParameters:parameters success:^(AFHTTPRequestOperation *op, id response) {
        NSArray *activityThreads = [self activityThreadArrayFromDictionaryArray:response[parameters]];
        [self setThreads:activityThreads];
        block();
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error downloading data. Please check your internet connection." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alert show];
    }];
    
}

@end
