//
//  FeedViewController.h
//  CSH WebNews
//
//  Created by Harlan Haskins on 8/27/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThreadsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (nonatomic) NSArray *threads;
@property (nonatomic) UITableView *tableView;
@end
