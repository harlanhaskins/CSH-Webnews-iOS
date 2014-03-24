//
//  NewsgroupsViewController.m
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "NewsgroupsViewController.h"
#import "NewsgroupOutlineTableViewModel.h"

@interface NewsgroupsViewController ()


@property (nonatomic) NewsgroupOutlineTableViewModel *tableViewModel;

@end

@implementation NewsgroupsViewController

- (instancetype) init {
    if (self = [super init]) {
        self.title = @"Newsgroups";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title
                                                        image:[UIImage imageNamed:@"NewsgroupTab.png"]
                                                          tag:0];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.tableViewModel = [NewsgroupOutlineTableViewModel new];
    
    __weak NewsgroupsViewController *weakSelf = self;
    self.tableViewModel.pushViewControllerBlock = ^(UIViewController* threadsVC) {
        [weakSelf.navigationController pushViewController:threadsVC animated:YES];
    };
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    self.tableView.delegate = self.tableViewModel;
    self.tableView.dataSource = self.tableViewModel;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventAllEvents];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
