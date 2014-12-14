//
//  ReplyViewController.h
//  CSH News
//
//  Created by Harlan Haskins on 3/12/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsgroupThread.h"

static NSString *const NewPostViewControllerPostWasSuccessfulNotification = @"NewPostViewControllerPostWasSuccessfulNotification";
static NSString *const NewPostViewControllerUserInfoPostKey = @"NewPostViewControllerUserInfoPostKey";
static NSString *const NewPostViewControllerUserInfoNewsgroupKey = @"NewPostViewControllerUserInfoNewsgroupKey";

@interface NewPostViewController : UITableViewController

@property (nonatomic) NewsgroupThread *post;
@property (nonatomic) NSString *newsgroup;
@property (nonatomic, getter = isReply) BOOL reply;

@end
