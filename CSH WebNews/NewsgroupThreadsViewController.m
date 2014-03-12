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

@interface NewsgroupThreadsViewController ()

@property (nonatomic) NewsgroupThreadListTableViewModel *tableViewModel;
@property (nonatomic) NewsgroupOutline *outline;

@end

@implementation NewsgroupThreadsViewController

+ (instancetype) threadListWithNewsgroupOutline:(NewsgroupOutline*)outline {
    NewsgroupThreadsViewController *threadsVC = [NewsgroupThreadsViewController new];
    threadsVC.outline = outline;
    threadsVC.title = threadsVC.outline.truncatedName;
    return threadsVC;
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventAllEvents];
    
    self.tableViewModel = [NewsgroupThreadListTableViewModel threadListWithNewsgroupOutline:self.outline];
    
    __weak NewsgroupThreadsViewController *weakself = self;
    self.tableViewModel.pushViewControllerBlock = ^(UIViewController *viewController) {
        [weakself.navigationController pushViewController:viewController animated:YES];
    };
    self.tableViewModel.loadDataBlock = ^{
        [weakself reloadTableView];
    };
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    self.tableView.delegate = self.tableViewModel;
    self.tableView.dataSource = self.tableViewModel;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                           target:self
                                                                                           action:@selector(newPost)];
    
    [self loadData];
}

- (void) newPost {
    NewPostViewController *newPost = [NewPostViewController postControllerWithNewsgroup:self.outline.name];
    [self.navigationController pushViewController:newPost animated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void) loadData {
    [self.tableViewModel loadData];
}

- (void) reloadTableView {
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

@end
