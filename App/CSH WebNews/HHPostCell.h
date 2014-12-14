//
//  HHPostCell.h
//  CSH News
//
//  Created by Harlan Haskins on 2/4/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HHPostCell;

@class NewsgroupThread;

@protocol HHPostCellDelegate <NSObject>

- (void)postCellDidTapReply:(HHPostCell *)postCell;
- (void)postCellDidTapStar:(HHPostCell *)postCell;

@end

static const NSInteger MaxIndentationLevel = 8;

/**
 The HHPostCell class represents a cell in a large table that contains a
 forum-style post and its children. Upon tapping the header, the view collapses itself 
 and all of its children.
 
 @since 1.0
 */
@interface HHPostCell : UITableViewCell

@property (weak, nonatomic) NewsgroupThread *post;
@property (weak, nonatomic) id<HHPostCellDelegate> delegate;

- (void) setStarFilling;

@end
