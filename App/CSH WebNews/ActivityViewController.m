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
#import "ActivityThread.h"
#import "ThreadPostsViewController.h"
#import "CSH_News-Swift.h"

@interface ActivityViewController ()<UISplitViewControllerDelegate>

@property (nonatomic, readwrite) ActivityTableViewModel *tableViewModel;
@property (nonatomic, readwrite) NSDate *lastUpdated;

@end

@implementation ActivityViewController

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;
    
    self.tabBarItem.image = [[UIImage imageNamed:@"ActivityTab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"SelectedActivityTab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.title = @"Activity";
    
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.tableViewModel = [ActivityTableViewModel new];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self.tableViewModel;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.0;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ThreadCell" bundle:nil]
         forCellReuseIdentifier:@"ThreadCell"];
    
    [self.tableView reloadData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"View Posts" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Prompt for API Key"]) {
        [segue.destinationViewController setCompletionBlock:^{
            [self loadData];
        }];
    }
    else if ([segue.identifier isEqualToString:@"View Posts"]) {
        ActivityThread *thread = self.tableViewModel.threads[[self.tableView indexPathForCell:sender].row];
        ThreadPostsViewController *postsVC = (ThreadPostsViewController*)[segue.destinationViewController topViewController];
        [postsVC setNewsgroup:thread.parentPost.newsgroup number:@(thread.parentPost.number) subject:thread.parentPost.subject];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkAPIKey];
}

- (void) checkAPIKey {
    if ([AuthenticationManager keyIsValid]) {
        [self loadData];
    }
    else {
        [self showAPIKeyViewController];
    }
}

- (void) showAPIKeyViewController {
    [self performSegueWithIdentifier:@"Prompt for API Key" sender:nil];
}

- (IBAction) loadData  {
    [self.tableViewModel loadDataWithBlock:^{
        [self reloadTableView];
    } invalidAPIKeyBlock:^(NSError *error) {
        if ([error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] statusCode] == 401) {
            [self showAPIKeyViewController];
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Error downloading data. Please check your internet connection." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Okay"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                          }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void) reloadTableView {
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
