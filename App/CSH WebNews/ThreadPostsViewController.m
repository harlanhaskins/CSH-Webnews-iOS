//
//  ThreadPostsViewController.m
//  CSH News
//
//  Created by Harlan Haskins on 2/5/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "ThreadPostsViewController.h"
#import "NewsgroupThread.h"
#import "Post.h"
#import "WebNewsDataHandler.h"
#import "NewPostViewController.h"
#import "HHThreadViewDataSource.h"
#import "HHPostCell.h"

@interface ThreadPostsViewController () <HHPostCellDelegate>

@property (nonatomic) NewsgroupThread *thread;
@property (nonatomic) HHThreadViewDataSource *dataSource;

@end

@implementation ThreadPostsViewController

- (void) setThread:(NewsgroupThread *)thread {
    _thread = thread;
    _thread.post.unread = NO;
    self.title = thread.post.subject;
    self.dataSource.posts = thread.allThreads;
    [self loadPosts];
}

- (void) postCellDidTapReply:(HHPostCell*)cell {
    NewsgroupThread *threadToReply = (NewsgroupThread *)cell.post;
    [self replyToPost:threadToReply];
}

- (void) postCellDidTapStar:(HHPostCell *)cell {
    NewsgroupThread *threadToStar = (NewsgroupThread *)cell.post;
    NSString *url = [NSString stringWithFormat:@"%@/%@/star", threadToStar.post.newsgroup, @(threadToStar.number)];
    [self toggleStarredOnCell:cell];
    [[WebNewsDataHandler sharedHandler] PUT:url
                                 parameters:nil
                                    success:^(NSURLSessionDataTask *task, id response) {
                                        BOOL starred = [response[@"starred"] boolValue];
                                        [self setStarred:starred onCell:cell];
                                    }
                                    failure:^(NSURLSessionDataTask *task, NSError *error) {
                                        [self toggleStarredOnCell:cell];
                                    }];
}

- (void) toggleStarredOnCell:(HHPostCell *)cell {
    NewsgroupThread *thread = (NewsgroupThread*)cell.post;
    [self setStarred:!thread.post.starred onCell:cell];
}

- (void) setStarred:(BOOL)starred onCell:(HHPostCell *)cell {
    NewsgroupThread *thread = (NewsgroupThread*)cell.post;
    thread.post.starred = starred;
    [cell setStarFilling];
}

- (void) postCellDidTapDelete:(HHPostCell *)cell {
    NewsgroupThread *threadToDelete = (NewsgroupThread*)cell.post;
    NSString *url = [NSString stringWithFormat:@"%@/%@", threadToDelete.post.newsgroup, @(threadToDelete.number)];
    NSDictionary *parameters = @{@"confirm_cancel" : @YES};
    [[WebNewsDataHandler sharedHandler] DELETE:url
                                    parameters:parameters
                                       success:^(NSURLSessionDataTask *task, id response) {
                                           [self reloadThread];
                                       }
                                       failure:nil];
}

- (IBAction) reloadThread {
    [self loadThreadWithNewsgroup:self.thread.post.newsgroup
                           number:@(self.thread.number)];
}

- (void) loadThreadWithNewsgroup:(NSString*)newsgroup number:(NSNumber*)number {
    NSString *url = [NSString stringWithFormat:@"%@/index", newsgroup];
    [[WebNewsDataHandler sharedHandler] GET:url
                                 parameters:@{@"from_number" : number}
                                    success:^(NSURLSessionDataTask *task, id response) {
                                        self.thread = [NewsgroupThread newsgroupThreadWithDictionary:response[@"posts_selected"]];
                                    }
                                    failure:^(NSURLSessionDataTask *task, NSError *error) {
                                        NSLog(@"Error: %@", error);
                                    }];
}

- (void) replyToPost:(NewsgroupThread *)post {
    [self performSegueWithIdentifier:@"New Reply" sender:post];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NewPostViewController *replyVC = (NewPostViewController*)[segue.destinationViewController topViewController];
    replyVC.post = sender;
    replyVC.reply = YES;
    replyVC.newsgroup = replyVC.post.post.newsgroup;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadThread)
                                                 name:NewPostViewControllerPostWasSuccessfulNotification
                                               object:replyVC];
}

- (void) awakeFromNib {
    self.dataSource = [HHThreadViewDataSource new];
    self.dataSource.delegate = self;
    self.tableView.dataSource = self.dataSource;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HHPostCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}

- (void) setNewsgroup:(NSString*)newsgroup number:(NSNumber*)number subject:(NSString*)subject {
    self.title = subject;
    [self loadThreadWithNewsgroup:newsgroup
                           number:number];
}

- (void) markThreadRead {
    NSDictionary *parameters = @{@"newsgroup" : self.thread.post.newsgroup,
                                 @"number" : @(self.thread.post.number),
                                 @"in_thread" : @YES};
    
    [[WebNewsDataHandler sharedHandler] PUT:@"mark_read" parameters:parameters success:nil failure:nil];
}

- (NSArray*) posts {
    return self.thread.allPosts;
}

- (void) loadPosts {
    [self markThreadRead];
    
    dispatch_group_t loadPostsGroup = dispatch_group_create();
    
    for (NewsgroupThread *thread in self.dataSource.posts) {
        dispatch_group_enter(loadPostsGroup);
        [thread.post loadBodyWithCompletion:^(NSError *error) {
            dispatch_group_leave(loadPostsGroup);
        }];
    }
    
    dispatch_group_notify(loadPostsGroup, dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    });
}

@end
