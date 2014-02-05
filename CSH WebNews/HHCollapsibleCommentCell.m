//
//  CollapsibleCommentCell.m
//  CSH News
//
//  Created by Harlan Haskins on 2/4/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "HHCollapsibleCommentCell.h"
#import "HHCellActionsView.h"

@interface HHCollapsibleCommentCell ()

@property (nonatomic) UIScrollView *bodyOptionsScroller;
@property (nonatomic, readwrite) HHCellActionsView *actionsView;

@property (nonatomic) UITextView *bodyView;
@property (nonatomic) UIButton *headerButton;

@end

@implementation HHCollapsibleCommentCell

+ (instancetype) new {
    HHCollapsibleCommentCell *cell = [HHCollapsibleCommentCell new];
    
    cell.bodyView = [UITextView new];
    cell.bodyView.scrollEnabled = NO;
    cell.bodyView.editable = NO;
    [cell addSubview:cell.bodyView];
    
    cell.indentationLevel = 1;
    cell.indentationWidth = 10.0;
    
    return cell;
}

+ (instancetype) cellWithActionView:(HHCellActionsView*)view {
    HHCollapsibleCommentCell *cell = [HHCollapsibleCommentCell new];
    
    cell.actionsView = view;
    
    cell.bodyOptionsScroller = [UIScrollView new];
    cell.bodyOptionsScroller.directionalLockEnabled = YES;
    cell.bodyOptionsScroller.pagingEnabled = YES;
    cell.bodyOptionsScroller.showsHorizontalScrollIndicator =
    cell.bodyOptionsScroller.showsVerticalScrollIndicator = NO;
    
    [cell.bodyView removeFromSuperview];
    
    [cell addSubview:cell.bodyOptionsScroller];
    [cell.bodyOptionsScroller addSubview:cell.bodyView];
    [cell.bodyOptionsScroller addSubview:cell.actionsView];
    
    return cell;
}

- (void) layoutSubviews {
    UIView *contentView = self.actionsView ? self.bodyOptionsScroller : self;
    
    CGRect frame = self.frame;
    frame.origin.x = (self.indentationLevel * self.indentationWidth);
    frame.size.width -= frame.origin.x;
    contentView.frame = frame;
    self.bodyOptionsScroller.contentSize = contentView.frame.size;
    
    self.bodyView.frame = contentView.frame;
    if (self.actionsView) {
        frame.origin.x += frame.size.width;
        self.actionsView.frame = frame;
    }
}

- (void) setText:(NSString *)text {
    self.bodyView.text = text;
    
    CGRect frame = self.bodyView.frame;
    frame.size.height = self.bodyView.contentSize.height;
    self.bodyView.frame = frame;
    
}

- (void) setAttributedText:(NSAttributedString*)text {
    self.bodyView.attributedText = text;
}

- (void) setHeaderText:(NSString*)headerText {
    [self.headerButton setTitle:headerText forState:UIControlStateNormal];
}

@end
