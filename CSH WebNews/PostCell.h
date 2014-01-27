//
//  PostCell.h
//  CSH News
//
//  Created by Harlan Haskins on 12/9/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Post;

@interface PostCell : UITableViewCell


@property (nonatomic, readonly) Post *post;
+ (NSString*) cellIdentifier;

@end
