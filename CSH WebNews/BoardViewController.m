//
//  BoardViewController.m
//  CSH WebNews
//
//  Created by Harlan Haskins on 9/20/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import "BoardViewController.h"
#import "ThreadsViewController.h"

@interface BoardViewController ()

@end

@implementation BoardViewController

@synthesize data;

- (id)initWithTitle:(NSString*)title
{
    self = [super init];
    if (self) {
        self.title = title;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    self.pathString = [self.title stringByAppendingString:@"/index"];
    
    self.specialParameters = @{@"limit" : @"20"};
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self checkAPIKey];
    
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
        NSDictionary *webNewsDictionary = [[WebNewsDataHandler sharedHandler] webNewsDataForViewController:self];
        data = webNewsDictionary[@"posts_older"];
        NSLog(@"Board Data: %@", data);
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!data) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Downloading News" message:@"There was an error downloading the data. Pleae check your internet connection and your API Key." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
            [alertView show];
        }
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [data count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"BoardCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *post = data[indexPath.row][@"post"];
    
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
        else {
            cell.textLabel.textColor = [UIColor blackColor];
        }
    }
    
    if (cell.userInteractionEnabled) {
        cell.accessory = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    NSDate *postDate = [[[ISO8601DateFormatter alloc] init] dateFromString:post[@"date"]];
    NSString *timeString = [dateFormatter stringFromDate:postDate];
    [dateFormatter setDateFormat:@"M-dd-yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:postDate];
    
    cell.textLabel.text = post[@"subject"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ at %@ on %@", post[@"author_name"], timeString, dateString];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *post = data[indexPath.row];
    ThreadsViewController *threadViewController = [[ThreadsViewController alloc] initWithParentPost:post];
    [self.navigationController pushViewController:threadViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
