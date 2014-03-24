//
//  FeedViewController.h
//  CSH WebNews
//
//  Created by Harlan Haskins on 8/27/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ActivityTableViewModel;

@interface ActivityViewController : UITableViewController

@property (nonatomic, readonly) ActivityTableViewModel *tableViewModel;
@property (nonatomic, readonly) NSDate *lastUpdated;

@end
