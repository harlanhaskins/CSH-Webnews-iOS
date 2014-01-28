//
//  FeedViewController.m
//  CSH WebNews
//
//  Created by Harlan Haskins on 8/27/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//
#import "ISO8601DateFormatter.h"
#import "ActivityViewController.h"
#import "ActivityThread.h"
#import "ActivityThreadCell.h"

@implementation ActivityViewController

- (instancetype) init {
    if (self = [super init]) {
        self.title = @"Activity";
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self checkAPIKey];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void) viewDidLayoutSubviews {
    self.tableView.frame = self.view.frame;
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
    if (!_lastUpdated || [[NSDate date] timeIntervalSinceDate:_lastUpdated] > 5*60) {
        _lastUpdated = [NSDate date];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        
        
        NSString *parameters = @"activity";
        
        [WebNewsDataHandler runHTTPOperationWithParameters:parameters success:^(AFHTTPRequestOperation *op, id response) {
            self.threads = [self arrayFromActivityDictionaries:response[@"activity"]];
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *op, NSError *error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Downloading News" message:@"There was an error downloading the data. Pleae check your internet connection and your API Key." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
                [alertView show];
        }];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

- (NSArray*) arrayFromActivityDictionaries:(NSArray*)dictionaries {
    NSMutableArray *activityThreads = [NSMutableArray array];
    for (NSDictionary* dictionary in dictionaries) {
        ActivityThread *thread = [ActivityThread activityThreadWithDictionary:dictionary];
        [activityThreads addObject:thread];
    }
    return activityThreads;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.threads count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"ActivityThreadCell_%i%i", indexPath.row, indexPath.section];
    ActivityThreadCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [ActivityThreadCell cellWithActivityThread:self.threads[indexPath.row] reuseIdentifier:cellIdentifier];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

@end
