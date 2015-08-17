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
#import "PostCell.h"
#import "RZCellSizeManager.h"
@import SafariServices;

@interface ThreadPostsViewController () <PostCellDelegate, SFSafariViewControllerDelegate>

@property (nonatomic) NewsgroupThread *thread;
@property (nonatomic) PostCell *templateCell;
@property (nonatomic) NSMutableDictionary *cellHeights;
@property (nonatomic) NSIndexPath *selectedPath;

@end

NSString *const kCellIdentifier = @"PostCell";

@implementation ThreadPostsViewController

- (void) setThread:(NewsgroupThread *)thread {
    _thread = thread;
    _thread.post.unread = NO;
    self.title = thread.post.subject;
    [self loadPosts];
}

- (void) postCellDidTapReply:(PostCell*)cell {
    NewsgroupThread *threadToReply = (NewsgroupThread *)cell.post;
    [self replyToPost:threadToReply];
}

- (void) postCellDidTapStar:(PostCell *)cell {
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

- (void) toggleStarredOnCell:(PostCell *)cell {
    NewsgroupThread *thread = (NewsgroupThread*)cell.post;
    [self setStarred:!thread.post.starred onCell:cell];
}

- (void) setStarred:(BOOL)starred onCell:(PostCell *)cell {
    NewsgroupThread *thread = (NewsgroupThread*)cell.post;
    thread.post.starred = starred;
    [cell setStarFilling];
}

- (void) postCellDidTapDelete:(PostCell *)cell {
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *postCellNib = [UINib nibWithNibName:@"PostCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:postCellNib forCellReuseIdentifier:kCellIdentifier];
    
    self.templateCell = [postCellNib instantiateWithOwner:nil options:nil].firstObject;
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

- (NSArray *) posts {
    return self.thread.allThreads;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell withPost:self.posts[indexPath.row]];
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rows = self.posts.count;
    [tableView addLoadingTextIfNecessaryForRows:rows withItemName:@"Posts"];
    return rows;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsgroupThread *post = self.thread.allThreads[indexPath.row];
    NSNumber *height = self.cellHeights[@(post.number)];
    if (height) {
        return height.doubleValue + 1.0;
    }
    [self configureCell:self.templateCell
               withPost:post];
    self.templateCell.frame = CGRectMake(0.0, 0.0, tableView.frame.size.width, self.templateCell.frame.size.height);
    [self.templateCell setNeedsLayout];
    [self.templateCell layoutIfNeeded];
    
    CGFloat cellHeight = [self.templateCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    self.cellHeights[@(self.templateCell.post.number)] = @(cellHeight);
    return cellHeight + 1.0;
}

- (void) configureCell:(PostCell*)cell withPost:(NewsgroupThread *)post {
    cell.post = post;
    cell.delegate = self;
}

- (void) loadPosts {
    [self markThreadRead];
    
    dispatch_group_t loadPostsGroup = dispatch_group_create();
    
    for (NewsgroupThread *thread in self.posts) {
        dispatch_group_enter(loadPostsGroup);
        [thread.post loadBodyWithCompletion:^(NSError *error) {
            dispatch_group_leave(loadPostsGroup);
        }];
    }
    
    dispatch_group_notify(loadPostsGroup, dispatch_get_main_queue(), ^{
        [self reloadTable];
    });
}

-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    SFSafariViewController *vc = [[SFSafariViewController alloc] initWithURL:url];
    vc.delegate = self;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)reloadTable {
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

@end
