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

@interface NewsgroupThreadListTableViewModel ()

@property (nonatomic, readwrite) NewsgroupOutline *outline;
@property (nonatomic, readwrite) NSArray *threads;

@end

@implementation NewsgroupThreadListTableViewModel
 
+ (instancetype) threadListWithNewsgroupOutline:(NewsgroupOutline*)outline {
    NewsgroupThreadListTableViewModel *model = [[NewsgroupThreadListTableViewModel alloc] init];
    model.outline = outline;
    return model;
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
}

- (void) loadDataWithBlock:(void(^)())block {
    NSString *parameters = [NSString stringWithFormat:@"%@/index", self.outline.name];
    
    [WebNewsDataHandler runHTTPOperationWithParameters:parameters success:^(AFHTTPRequestOperation *op, id response) {
        NSArray *threads = [self newsgroupThreadsFromNewsgroupThreadDictionaryArray:response[@"posts_older"]];
        [self setThreads:threads];
        block();
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
