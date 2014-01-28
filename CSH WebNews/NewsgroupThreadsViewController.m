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

@interface NewsgroupThreadsViewController ()

@property (nonatomic) NewsgroupThreadListTableViewModel *tableViewModel;
@property (nonatomic) NewsgroupOutline *outline;

@end

@implementation NewsgroupThreadsViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"Newsgroups";
    }
    return self;
}

+ (instancetype) threadListWithNewsgroupOutline:(NewsgroupOutline*)outline {
    NewsgroupThreadsViewController *threadsVC = [NewsgroupThreadsViewController new];
    threadsVC.outline = outline;
    return threadsVC;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.tableViewModel = [NewsgroupThreadListTableViewModel threadListWithNewsgroupOutline:self.outline];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    self.tableView.delegate = self.tableViewModel;
    self.tableView.dataSource = self.tableViewModel;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventAllEvents];
    
    [self loadData];
}

- (void) loadData {
    [self.tableViewModel loadDataWithBlock:^{
        [self reloadTableView];
    }];
}

- (void) reloadTableView {
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

@end
