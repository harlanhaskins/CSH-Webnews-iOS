//
//  HHThreadViewDataSource.m
//  Pods
//
//  Created by Harlan Haskins on 7/20/14.
//
//

#import "HHThreadViewDataSource.h"
#import "HHPostCell.h"
#import "NewsgroupThread.h"

@implementation HHThreadViewDataSource

+ (instancetype) dataSourceWithPosts:(NSArray*)posts {
    HHThreadViewDataSource *dataSource = [HHThreadViewDataSource new];
    dataSource.posts = posts;
    return dataSource;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HHPostCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rows = self.posts.count;
    [tableView addLoadingTextIfNecessaryForRows:rows withItemName:@"Posts"];
    return rows;
}

- (void) configureCell:(HHPostCell*)cell forIndexPath:(NSIndexPath*)indexPath {
    NSUInteger postIndex = indexPath.row;
    cell.post = self.posts[postIndex];
    cell.indentationLevel = cell.post.depth;
    cell.delegate = self.delegate;
    cell.tag = postIndex;
}

@end
