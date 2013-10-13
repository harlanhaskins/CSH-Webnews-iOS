//
//  PostViewController.h
//  CSH WebNews
//
//  Created by Harlan Haskins on 9/20/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebNewsDataHandler.h"
#import "APIKeyViewController.h"

@interface PostViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, WebNewsDataHandlerProtocol, APIKeyDelegate>

@property (strong, nonatomic) NSArray *data;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSString *pathString;
@property (nonatomic) NSString *number;
@property (nonatomic) NSDate *lastUpdated;
@end
