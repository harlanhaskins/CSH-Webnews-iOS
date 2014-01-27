//
//  FeedViewController.h
//  CSH WebNews
//
//  Created by Harlan Haskins on 8/27/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebNewsDataHandler.h"
#import "APIKeyViewController.h"

@interface ActivityViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *threads;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSDate *lastUpdated;

@end
