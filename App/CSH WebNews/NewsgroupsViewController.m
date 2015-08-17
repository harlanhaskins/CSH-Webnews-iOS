//
//  NewsgroupsViewController.m
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "NewsgroupsViewController.h"
#import "NewsgroupOutlineTableViewModel.h"
#import "NewsgroupThreadsViewController.h"

@interface NewsgroupsViewController ()

@property (nonatomic) NewsgroupOutlineTableViewModel *tableViewModel;

@end

@implementation NewsgroupsViewController

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;
    
    self.tabBarItem.image = [[UIImage imageNamed:@"NewsgroupTab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"SelectedNewsgroupTab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.title = @"Newsgroups";
    
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.tableViewModel = [NewsgroupOutlineTableViewModel new];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self.tableViewModel;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadData];
}

- (IBAction) loadData {
    [self.refreshControl beginRefreshing];
    [self.tableViewModel loadDataWithBlock:^{
        [self reloadTableView];
    }];
}

- (void) reloadTableView {
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (IBAction) unwind:(UIStoryboardSegue*)segue {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"View Threads"]) {
        NewsgroupThreadsViewController *threadsVC = segue.destinationViewController;
        threadsVC.outline = self.tableViewModel.newsgroups[self.tableView.indexPathForSelectedRow.row];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
