//
//  NewsgroupThreadsViewController.m
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "NewsgroupThreadsViewController.h"
#import "NewsgroupThread.h"
#import "NewsgroupThreadListTableViewModel.h"
#import "NewsgroupOutline.h"
#import "NewPostViewController.h"
#import "ThreadPostsViewController.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "CSH_News-Swift.h"

@interface NewsgroupThreadsViewController ()

@property (nonatomic) NewsgroupThreadListTableViewModel *tableViewModel;

@end

@implementation NewsgroupThreadsViewController

- (void) setOutline:(NewsgroupOutline *)outline {
    _outline = outline;
    self.title = outline.truncatedName;
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableViewModel = [NewsgroupThreadListTableViewModel threadListWithNewsgroupOutline:self.outline];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ThreadCell" bundle:nil]
         forCellReuseIdentifier:@"ThreadCell"];
    
    __weak NewsgroupThreadsViewController *weakself = self;
    self.tableViewModel.loadDataBlock = ^{
        [weakself reloadTableView];
        [weakself.tableView.infiniteScrollingView stopAnimating];
    };
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakself.tableViewModel loadMorePosts];
    }];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self.tableViewModel;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.0;
    
    if (!self.outline.postable) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (IBAction) unwind:(UIStoryboardSegue*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    [self loadData];
    [self reloadTableView];
}

- (IBAction) loadData {
    [self.tableViewModel loadData];
}

- (void) reloadTableView {
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier hasPrefix:@"View Posts"]) {
        ThreadPostsViewController *postsVC = (ThreadPostsViewController*)[segue.destinationViewController topViewController];
        NewsgroupThread *thread = self.tableViewModel.threads[[self.tableView indexPathForCell:sender].row];
        [postsVC setNewsgroup:thread.post.newsgroup number:@(thread.number) subject:thread.subject];
    }
    else if ([segue.identifier isEqualToString:@"New Post"]) {
        NewPostViewController *newPostVC = (NewPostViewController*)[segue.destinationViewController topViewController];
        newPostVC.newsgroup = self.outline.name;
        newPostVC.reply = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNewPost)
                                                     name:NewPostViewControllerPostWasSuccessfulNotification
                                                   object:newPostVC];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"View Posts" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

- (void) handleNewPost {
    [self dismissViewControllerAnimated:YES completion:^{
        [self reloadTableView];
    }];
}

@end
