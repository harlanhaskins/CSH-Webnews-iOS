//
//  ThreadViewController.m
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "ThreadDetailViewController.h"
#import "ThreadDetailTableViewModel.h"
#import "NewsgroupThread.h"
#import "Post.h"

@interface ThreadDetailViewController ()

@property (nonatomic, readwrite) ThreadDetailTableViewModel *tableViewModel;
@property (nonatomic, readwrite) NewsgroupThread *thread;

@end

@implementation ThreadDetailViewController

+ (instancetype) threadViewControllerWithThread:(NewsgroupThread*)thread {
    ThreadDetailViewController *threadVC = [ThreadDetailViewController new];
    threadVC.thread = thread;
    threadVC.title = thread.post.subject;
    
    threadVC.refreshControl = [UIRefreshControl new];
    [threadVC.refreshControl addTarget:threadVC action:@selector(didLoadData) forControlEvents:UIControlEventAllEvents];
    
    threadVC.tableViewModel = [ThreadDetailTableViewModel modelWithPosts:threadVC.thread.allPosts];
    
    __weak ThreadDetailViewController *weakThreadView = threadVC;
    threadVC.tableViewModel.reloadTableViewBlock = ^{
        [weakThreadView didLoadData];
    };
    
    threadVC.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    threadVC.tableView.delegate = threadVC.tableViewModel;
    threadVC.tableView.dataSource = threadVC.tableViewModel;
    
    return threadVC;
}

- (void) didLoadData {
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
