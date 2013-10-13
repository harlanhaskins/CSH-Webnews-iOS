//
//  BoardViewController.m
//  CSH WebNews
//
//  Created by Harlan Haskins on 9/20/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import "BoardViewController.h"

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
    
    [self checkAPIKey];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.pathString = [self.title stringByAppendingString:@"/index"];
    
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
        data = [[WebNewsDataHandler sharedHandler] webNewsDataForViewController:self];
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
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
