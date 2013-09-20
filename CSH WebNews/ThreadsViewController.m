//
//  FeedViewController.m
//  CSH WebNews
//
//  Created by Harlan Haskins on 8/27/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//
#import "WebNewsDataHandler.h"
#import "ISO8601DateFormatter.h"
#import "ThreadsViewController.h"

@implementation ThreadsViewController {
    NSString *baseURL;
    NSArray *newsgroups;
}

-(id) init {
    if (self = [super init]) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
        
        NSString *apiKey = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"api_key"];
        if (!apiKey) {
            UIAlertView *apiKeyAlertView = [[UIAlertView alloc] initWithTitle:@"API Key Needed" message:@"You can't use Web News until you type in your API key. You can find it in Settings." delegate:self cancelButtonTitle:@"Nah, I don't want to use WebNews." otherButtonTitles:@"Okay!", nil];
            apiKeyAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
            [apiKeyAlertView show];
        }
        else {
            _threads = [[WebNewsDataHandler sharedHandler] webNewsDataForPath:@"activity"];
            [self.tableView reloadData];
        }
        
    }
    return self;
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *apiKey = [alertView textFieldAtIndex:0].text ;
    if (![apiKey isEqualToString:@""]) {
        [[PDKeychainBindings sharedKeychainBindings] setObject:apiKey forKey:@"api_key"];
        _threads = [[WebNewsDataHandler sharedHandler] webNewsDataForPath:@"activity"];
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
        NSDictionary *thread = _threads[indexPath.row];
        NSDictionary *newestPost = thread[@"newest_post"];
        cell.textLabel.text = newestPost[@"subject"];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        NSDate *postDate = [[[ISO8601DateFormatter alloc] init] dateFromString:newestPost[@"date"]];
        NSString *timeString = [dateFormatter stringFromDate:postDate];
        [dateFormatter setDateFormat:@"MM-dd-yyyy"];
        NSString *dateString = [dateFormatter stringFromDate:postDate];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ in %@ at %@ on %@", newestPost[@"author_name"], newestPost[@"newsgroup"], timeString, dateString];
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
