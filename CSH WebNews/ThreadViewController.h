//
//  ThreadViewController.h
//  CSH News
//
//  Created by Harlan Haskins on 10/15/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebNewsDataHandler.h"
#import "APIKeyViewController.h"

@interface ThreadViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, WebNewsDataHandlerProtocol, APIKeyDelegate>

@property (strong, nonatomic) NSDictionary *parentPost;
@property (strong, nonatomic) NSArray *data;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSString *pathString;
@property (nonatomic) NSString *number;
@property (nonatomic) NSDate *lastUpdated;

- (instancetype) initWithParentPost:(NSDictionary*)parentPost;

@end
