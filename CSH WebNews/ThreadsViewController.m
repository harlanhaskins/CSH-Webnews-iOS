//
//  FeedViewController.m
//  CSH WebNews
//
//  Created by Harlan Haskins on 8/27/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import "User.h"
#import "ThreadsViewController.h"

@implementation ThreadsViewController {
    NSString *baseURL;
}

-(id) init {
    if (self = [super init]) {
        _threads = [NSArray new];
        _threads = @[@{@"title":@"Post Title", @"text":@"This is a Web News post."}];
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
        
        baseURL = @"https://webnews.csh.rit.edu/";
        
        NSString *apiKey = [[PDKeychainBindings sharedKeychainBindings] valueForKey:@"api_key"];
        if (!apiKey) {
            UIAlertView *apiKeyAlertView = [[UIAlertView alloc] initWithTitle:@"API Key Needed" message:@"You can't use Web News until you type in your API key You can find it in Settings." delegate:self cancelButtonTitle:@"Nah, I don't want to use WebNews." otherButtonTitles:@"Okay!", nil];
            apiKeyAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
            [apiKeyAlertView show];
        }
        else {
            [self authenticateAndDownloadData];
        }
        
    }
    return self;
}
    
- (void) authenticateAndDownloadData {
    NSString *apiKey = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"api_key"];
    NSDictionary *parameters = @{@"api_key":apiKey, @"api_agent":@"iOS"};
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    client.defaultSSLPinningMode = AFSSLPinningModeCertificate;
    
    [client getPath:@"newsgroups" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *apiKey = [alertView textFieldAtIndex:0].text ;
    if (![apiKey isEqualToString:@""]) {
        [[PDKeychainBindings sharedKeychainBindings] setObject:apiKey forKey:@"api_key"];
        [self authenticateAndDownloadData];
    }
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_threads count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ThreadCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.textLabel.text = _threads[0][@"title"];
        cell.detailTextLabel.text = _threads[0][@"text"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
