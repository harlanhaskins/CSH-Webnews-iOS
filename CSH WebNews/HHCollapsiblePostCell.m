//
//  CollapsibleCommentCell.m
//  CSH News
//
//  Created by Harlan Haskins on 2/4/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "HHCollapsiblePostCell.h"
#import "HHCollapsiblePostCellActionsView.h"
#import "HHPostProtocol.h"

@interface HHCollapsiblePostCell ()

@property (nonatomic) UIScrollView *bodyOptionsScroller;
@property (nonatomic, readwrite) HHCollapsiblePostCellActionsView *actionsView;

@property (nonatomic) UITextView *bodyView;
@property (nonatomic) UIButton *headerButton;

@property (nonatomic) NSArray *children;

@end

@implementation HHCollapsiblePostCell

+ (instancetype) new {
    HHCollapsiblePostCell *cell = [[HHCollapsiblePostCell alloc] init];
    
    cell.bodyView = [UITextView new];
    cell.bodyView.scrollEnabled = NO;
    cell.bodyView.editable = NO;
    [cell addSubview:cell.bodyView];
    
//    cell.backgroundColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.5];
//    cell.bodyView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.5];
    
    cell.indentationLevel = 1;
    cell.indentationWidth = 10.0;
    
    return cell;
}

+ (instancetype) cellWithPost:(id<HHPostProtocol>)post {
    return [self cellWithPost:post atDepth:0];
}

+ (instancetype) cellWithPost:(id<HHPostProtocol>)post atDepth:(NSUInteger)depth {
    HHCollapsiblePostCell *cell = [HHCollapsiblePostCell new];
    
    cell.bodyOptionsScroller = [UIScrollView new];
    cell.bodyOptionsScroller.directionalLockEnabled = YES;
    cell.bodyOptionsScroller.pagingEnabled = YES;
    cell.bodyOptionsScroller.showsHorizontalScrollIndicator =
    cell.bodyOptionsScroller.showsVerticalScrollIndicator = NO;
    
    cell.indentationLevel = depth;
    
    cell.post = post;
    [cell.headerButton setTitle:post.headerText forState:UIControlStateNormal];
    cell.children = [cell childrenFromPost:post];
    
    [cell.bodyView removeFromSuperview];
    
    [cell addSubview:cell.bodyOptionsScroller];
    [cell.bodyOptionsScroller addSubview:cell.bodyView];
    [cell.bodyOptionsScroller addSubview:cell.actionsView];
    
    return cell;
}

- (NSArray*) childrenFromPost:(id<HHPostProtocol>)post {
    return [self recursiveChildrenFromPost:post atDepth:0];
}

- (NSArray*) recursiveChildrenFromPost:(id<HHPostProtocol>)post atDepth:(NSUInteger)depth {
    NSMutableArray *postCells = [NSMutableArray array];
    for (id<HHPostProtocol> post in self.post.children) {
        HHCollapsiblePostCell *cell = [HHCollapsiblePostCell cellWithPost:post atDepth:(depth + 1)];
        [postCells addObject:cell];
    }
    return postCells;
}

- (void) layoutSubviews {
    
    CGRect frame = self.frame;
    frame.origin.x = (self.indentationLevel * self.indentationWidth);
    frame.size.width -= frame.origin.x;
    self.bodyOptionsScroller.frame = frame;
    
    self.bodyView.frame = self.bodyOptionsScroller.frame;
    if (self.actionsView) {
        frame.origin.x += frame.size.width;
        self.actionsView.frame = frame;
    }
}

- (void) setAttributedText:(NSAttributedString*)text {
    self.bodyView.attributedText = text;
}

- (void) setHeaderText:(NSString*)headerText {
    [self.headerButton setTitle:headerText forState:UIControlStateNormal];
}

- (CGSize) sizeThatFits:(CGSize)size {
    self.bodyView.text = self.post.bodyText;
    CGSize textSize = [self.bodyView sizeThatFits:size];
    return textSize;
}

@end
