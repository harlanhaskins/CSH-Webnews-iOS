//
//  ThreadPostsViewController.h
//  CSH News
//
//  Created by Harlan Haskins on 2/5/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsgroupThread;

@interface ThreadPostsViewController : UITableViewController

- (void) loadPosts;
- (void) setNewsgroup:(NSString*)newsgroup number:(NSNumber*)number subject:(NSString*)subject;

@end
