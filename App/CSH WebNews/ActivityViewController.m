//
//  FeedViewController.m
//  CSH WebNews
//
//  Created by Harlan Haskins on 8/27/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//
#import "ISO8601DateFormatter.h"
#import "ActivityViewController.h"
#import "ActivityTableViewModel.h"
#import "APIKeyViewController.h"
#import "WebNewsDataHandler.h"
#import "NewsgroupThread.h"
#import "ThreadPostsViewController.h"

@interface ActivityViewController ()

@property (nonatomic, readwrite) UITableView *tableView;
@property (nonatomic, readwrite) ActivityTableViewModel *tableViewModel;
@property (nonatomic, readwrite) NSDate *lastUpdated;

@end

@implementation ActivityViewController

- (instancetype) init {
    if (self = [super init]) {
        self.title = @"Activity";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title
                                                        image:[UIImage imageNamed:@"ActivityTab.png"]
                                                          tag:0];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.tableViewModel = [ActivityTableViewModel new];
    
    __weak ActivityViewController *weakSelf = self;
    self.tableViewModel.didSelectCellBlock = ^(NewsgroupThread* thread) {
        ThreadPostsViewController *postsVC = [ThreadPostsViewController controllerWithThread:thread];
        postsVC.reloadThreadsBlock = ^ {
            [weakSelf loadData];
        };
        [weakSelf.navigationController pushViewController:postsVC animated:YES];
    };
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    self.tableView.delegate = self.tableViewModel;
    self.tableView.dataSource = self.tableViewModel;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventAllEvents];
//    [self.view addSubview:self.tableView];
}

- (void) viewDidLayoutSubviews {
    self.tableView.frame = self.view.frame;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkAPIKey];
}

- (void) checkAPIKey {
    NSString *apiKey = [[PDKeychainBindings sharedKeychainBindings] objectForKey:kApiKeyKey];
    if (!apiKey || [apiKey isEqualToString:@"NULL_API_KEY"]) {
        APIKeyViewController *apiKeyViewController = [[APIKeyViewController alloc] init];
        
        [apiKeyViewController setCompletionBlock:^{
            [self loadData];
        }];
        
        [self presentViewController:apiKeyViewController animated:YES completion:nil];
    }
    else {
        [self loadData];
    }
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
