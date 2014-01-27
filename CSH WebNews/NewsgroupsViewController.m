//
//  NewsgroupsViewController.m
//  CSH WebNews
//
//  Created by Harlan Haskins on 9/20/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import "NewsgroupsViewController.h"
#import "BoardViewController.h"

@interface NewsgroupsViewController ()

@end

@implementation NewsgroupsViewController

@synthesize data;

- (instancetype) init {
    if (self = [super init]) {
        self.title = @"Newsgroups";
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
    self.tableView.size = self.view.size;
    self.tableView.origin = CGPointZero;
}

- (void) checkAPIKey {
    NSString *apiKey = [[PDKeychainBindings sharedKeychainBindings] objectForKey:kApiKeyKey];
    if (!apiKey || [apiKey isEqualToString:@"NULL_API_KEY"]) {
        APIKeyViewController *apiKeyViewController = [[APIKeyViewController alloc] init];
        apiKeyViewController.delegate = self;
        [self presentViewController:apiKeyViewController animated:YES completion:nil];
    }
    else {
        [self loadData];
    }
}

- (void) loadData {
    if (!_lastUpdated || [[NSDate date] timeIntervalSinceDate:_lastUpdated] > 5 * 60) {
        _lastUpdated = [NSDate date];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSDictionary *webNewsDictionary = [WebNewsDataHandler webNewsDataForViewController:self];
        data = webNewsDictionary[self.title.lowercaseString];
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!data) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Downloading News" message:@"There was an error downloading the data. Pleae check your internet connection and your API Key." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
            [alertView show];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"NewsgroupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSDictionary *newsgroup = data[indexPath.row];
    NSString *postClass = newsgroup[@"unread_class"];
    
    if (![postClass isKindOfClass:[NSNull class]]) {
        if ([postClass isEqualToString:@"mine"]) {
            cell.textLabel.textColor = [UIColor colorWithRed:0.000 green:0.814 blue:0.000 alpha:1.000];
        }
        else if ([postClass isEqualToString:@"mine_in_thread"]) {
            cell.textLabel.textColor = [UIColor colorWithRed:0.415 green:0.000 blue:0.414 alpha:1.000];
        }
        else if ([postClass isEqualToString:@"mine_reply"]) {
            cell.textLabel.textColor = [UIColor colorWithRed:0.953 green:0.268 blue:0.935 alpha:1.000];
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    NSDate *postDate = [[[ISO8601DateFormatter alloc] init] dateFromString:newsgroup[@"newest_date"]];
    NSString *timeString = [dateFormatter stringFromDate:postDate];
    [dateFormatter setDateFormat:@"M-dd-yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:postDate];
    NSInteger unreadCount = [newsgroup[@"unread_count"] integerValue];
    NSString *unread = unreadCount ? [NSString stringWithFormat:@" (%d)", unreadCount] : @"";
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@", newsgroup[@"name"], unread];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Last Post - %@ on %@", timeString, dateString];
    cell.textLabel.numberOfLines = 2;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *board = data[indexPath.row];
    BoardViewController *boardVC = [[BoardViewController alloc] initWithTitle:board[@"name"]];
    [self.navigationController pushViewController:boardVC animated:YES];
}

@end
