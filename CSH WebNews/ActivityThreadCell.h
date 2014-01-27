//
//  ActivityThreadCell.h
//  CSH News
//
//  Created by Harlan Haskins on 1/26/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActivityThread;

@interface ActivityThreadCell : UITableViewCell

@property (nonatomic, readonly) ActivityThread *thread;

+ (instancetype) cellWithActivityThread:(ActivityThread*)thread;

+ (NSString*) cellIdentifier;

@end
