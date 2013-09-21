//
//  FeedViewController.m
//  CSH WebNews
//
//  Created by Harlan Haskins on 8/27/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//
#import "ISO8601DateFormatter.h"
#import "ActivityViewController.h"
#import "PostViewController.h"

@implementation ActivityViewController
@synthesize data;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Activity";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void) viewDidAppear:(BOOL)animated {
    [self loadData];
}

- (void) loadData {
    if (!_lastUpdated || [[NSDate date] timeIntervalSinceDate:_lastUpdated] > 5*60) {
        _lastUpdated = [NSDate date];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        data = [[WebNewsDataHandler sharedHandler] webNewsDataForViewController:self];
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!data) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Downloading News" message:@"There was an error downloading the data. Pleae check your internet connection and your API Key." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
            [alertView show];
        }
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [data count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ActivityCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        NSDictionary *thread = data[indexPath.row];
        NSDictionary *newestPost = thread[@"newest_post"];
        cell.textLabel.text = newestPost[@"subject"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        NSDate *postDate = [[[ISO8601DateFormatter alloc] init] dateFromString:newestPost[@"date"]];
        NSString *timeString = [dateFormatter stringFromDate:postDate];
        [dateFormatter setDateFormat:@"M-dd-yyyy"];
        NSString *dateString = [dateFormatter stringFromDate:postDate];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ in %@ at %@ on %@", newestPost[@"author_name"], newestPost[@"newsgroup"], timeString, dateString];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *number = data[indexPath.row][@"newest_post"][@"number"];
    NSString *pathString = data[indexPath.row][@"thread_parent"][@"newsgroup"];
    PostViewController *postViewController = [[PostViewController alloc] init];
    postViewController.pathString = [pathString stringByAppendingString:[NSString stringWithFormat:@"/%@", number]];
    [self.navigationController pushViewController:postViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
