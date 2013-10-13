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

@interface ActivityViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, WebNewsDataHandlerProtocol, APIKeyDelegate>

@property (strong, nonatomic) NSArray *data;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSDate *lastUpdated;

@end
