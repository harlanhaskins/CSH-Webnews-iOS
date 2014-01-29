//
//  ThreadTableViewModel.m
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "ThreadDetailTableViewModel.h"
#import "Post.h"

@interface ThreadDetailTableViewModel ()

@property (nonatomic) NSArray *posts;

@end

@implementation ThreadDetailTableViewModel

+ (instancetype) modelWithPosts:(NSArray*)posts {
    ThreadDetailTableViewModel *model = [ThreadDetailTableViewModel new];
    model.posts = posts;
    return model;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.posts count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Post *post = self.posts[indexPath.row];
    PostCell *cell = [post cellFromPost];
    return cell;
}

- (void) setPosts:(NSArray *)posts {
    _posts = posts;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
