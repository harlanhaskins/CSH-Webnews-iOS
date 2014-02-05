//
//  CollapsibleCommentCell.h
//  CSH News
//
//  Created by Harlan Haskins on 2/4/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HHCellActionsView;

@interface HHCollapsibleCommentCell : UIView

@property (nonatomic) NSInteger indentationLevel;

@property (nonatomic) CGFloat indentationWidth;

@property (nonatomic, readonly) HHCellActionsView *actionsView;

- (void) setText:(NSString*)text;

@end
