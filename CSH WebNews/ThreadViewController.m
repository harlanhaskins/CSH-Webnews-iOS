//
//  PostViewController.m
//  CSH WebNews
//
//  Created by Harlan Haskins on 9/20/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import "ThreadViewController.h"

@interface ThreadViewController ()

@end

@implementation ThreadViewController

@synthesize data;
@synthesize parentPost;

- (id)initWithParentPost:(NSDictionary *)theParentPost
{
    self = [super init];
    if (self) {
        parentPost = theParentPost;
        data = parentPost[@"children"];
    }
    return self;
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
    if (!_lastUpdated || [[NSDate date] timeIntervalSinceDate:_lastUpdated] > 5*60) {
        _lastUpdated = [NSDate date];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        data = [[WebNewsDataHandler sharedHandler] webNewsDataForViewController:self][self.title];
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!data) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Downloading News" message:@"There was an error downloading the data. Pleae check your internet connection and your API Key." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
            [alertView show];
        }
    }
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView reloadData];
    
    [self.view addSubview:self.tableView];
    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return data.count + 1;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"BoardCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *post;
    if (indexPath.row == 0) {
        post = parentPost[@"post"];
        cell.userInteractionEnabled = NO;
    }
    else {
        post = data[indexPath.row - 1][@"post"];
        cell.userInteractionEnabled = [data[indexPath.row - 1][@"children"] count] > 0;
    }
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    NSDate *postDate = [[[ISO8601DateFormatter alloc] init] dateFromString:post[@"date"]];
    NSString *timeString = [dateFormatter stringFromDate:postDate];
    [dateFormatter setDateFormat:@"M-dd-yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:postDate];
    
    NSString *class = post[@"personal_class"];
    
    if (![class isKindOfClass:[NSNull class]]) {
        if ([class isEqualToString:@"mine"]) {
            cell.textLabel.textColor = [UIColor greenColor];
        }
        else if ([class isEqualToString:@"mine_in_thread"]) {
            cell.textLabel.textColor = [UIColor purpleColor];
        }
        else if ([class isEqualToString:@"mine_reply"]) {
            cell.textLabel.textColor = [UIColor magentaColor];
        }
    }
    
    cell.textLabel.text = post[@"subject"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ at %@ on %@", post[@"author_name"], timeString, dateString];
    
    if (indexPath.row > 0) {
        cell.textLabel.x += 5.0;
        cell.detailTextLabel.x += 5.0;
        cell.textLabel.width -= 5.0;
        cell.detailTextLabel.width -= 5.0;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *post = data[indexPath.row - 1];
    ThreadViewController *threadViewController = [[ThreadViewController alloc] initWithParentPost:post];
    [self.navigationController pushViewController:threadViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
