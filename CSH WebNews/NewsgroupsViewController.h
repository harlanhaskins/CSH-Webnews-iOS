//
//  NewsgroupsViewController.h
//  CSH WebNews
//
//  Created by Harlan Haskins on 9/20/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebNewsDataHandler.h"
#import "APIKeyViewController.h"
#import "AppDelegate.h"

@interface NewsgroupsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, WebNewsDataHandlerProtocol, APIKeyDelegate>

@property (strong, nonatomic) NSArray *data;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSDate *lastUpdated;

@end
