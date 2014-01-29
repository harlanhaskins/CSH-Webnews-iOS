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
@property (nonatomic) NSInteger postsLoaded;

@end

@implementation ThreadDetailTableViewModel

+ (instancetype) modelWithPosts:(NSArray*)posts {
    ThreadDetailTableViewModel *model = [ThreadDetailTableViewModel new];
    model.posts = posts;
    return model;
}

- (void) setReloadTableViewBlock:(void (^)())reloadTableViewBlock {
    _reloadTableViewBlock = reloadTableViewBlock;
    [self loadPosts];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.posts count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Post *post = self.posts[indexPath.row];
    
    CGFloat CELL_CONTENT_MARGIN = 10.0 * (post.depth / 2);
    
    CGSize constraint = CGSizeMake(tableView.width - (CELL_CONTENT_MARGIN * 2), 2000.0);
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0]};
    
    CGSize size = [post.body boundingRectWithSize:constraint
                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                  attributes:attributes
                                     context:nil].size;
    
    CGFloat height = ceil(MAX(size.height + 50.0, 34.0));
    
    return height;
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

- (void) loadPosts {
    for (Post *post in self.posts) {
        [post loadBodyWithBlock:^(Post *currentPost) {
            self.postsLoaded++;
        }];
    }
    while (self.postsLoaded < self.posts.count) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
    }
    self.reloadTableViewBlock();
}

@end
