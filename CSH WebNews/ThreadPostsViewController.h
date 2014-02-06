//
//  ThreadPostsViewController.h
//  CSH News
//
//  Created by Harlan Haskins on 2/5/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsgroupThread;

@interface ThreadPostsViewController : UIViewController

+ (instancetype) controllerWithThread:(NewsgroupThread*)thread;

@end
