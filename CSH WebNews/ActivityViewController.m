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
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    self.tableView.delegate = self.tableViewModel;
    self.tableView.dataSource = self.tableViewModel;
    [self.view addSubview:self.tableView];
    
    [self checkAPIKey];
}

- (void) viewDidLayoutSubviews {
    self.tableView.frame = self.view.frame;
}

- (void) checkAPIKey {
    NSString *apiKey = [[PDKeychainBindings sharedKeychainBindings] objectForKey:kApiKeyKey];
    if (!apiKey || [apiKey isEqualToString:@"NULL_API_KEY"]) {
        APIKeyViewController *apiKeyViewController = [[APIKeyViewController alloc] init];
        
        [apiKeyViewController setCompletionBlock:^{
            [self.tableViewModel loadDataWithBlock:^{
                [self.tableView reloadData];
            }];
        }];
        
        [self presentViewController:apiKeyViewController animated:YES completion:nil];
    }
    else {
        [self.tableViewModel loadDataWithBlock:^{
            [self.tableView reloadData];
        }];
    }
}

@end
