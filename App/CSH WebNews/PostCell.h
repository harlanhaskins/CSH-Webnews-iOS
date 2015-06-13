//
//  PostCell.h
//  CSH News
//
//  Created by Harlan Haskins on 2/4/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@class PostCell;

@class NewsgroupThread;

@protocol PostCellDelegate <NSObject, TTTAttributedLabelDelegate>

- (void)postCellDidTapReply:(PostCell *)postCell;
- (void)postCellDidTapStar:(PostCell *)postCell;

@end

static const NSInteger MaxIndentationLevel = 8;

/**
 The PostCell class represents a cell in a large table that contains a
 forum-style post and its children. Upon tapping the header, the view collapses itself 
 and all of its children.
 
 @since 1.0
 */
@interface PostCell : UITableViewCell

@property (weak, nonatomic) NewsgroupThread *post;
@property (weak, nonatomic) id<PostCellDelegate> delegate;

- (void) setStarFilling;

@end
