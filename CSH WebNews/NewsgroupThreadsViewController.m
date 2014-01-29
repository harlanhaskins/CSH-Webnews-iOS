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

+ (instancetype) threadListWithNewsgroupOutline:(NewsgroupOutline*)outline {
    NewsgroupThreadsViewController *threadsVC = [NewsgroupThreadsViewController new];
    threadsVC.outline = outline;
    threadsVC.title = @"Newsgroups";
    
    
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
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    self.tableView.delegate = self.tableViewModel;
    self.tableView.dataSource = self.tableViewModel;
    
    [self loadData];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
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
