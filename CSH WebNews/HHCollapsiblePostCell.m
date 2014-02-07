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

@property (nonatomic, readwrite) HHCollapsiblePostCellActionsView *actionsView;

@property (nonatomic) UITextView *bodyView;
@property (nonatomic) UIButton *headerButton;

@end

@implementation HHCollapsiblePostCell

+ (instancetype) new {
    HHCollapsiblePostCell *cell = [[HHCollapsiblePostCell alloc] init];
    
    cell.bodyView = [UITextView new];
    cell.bodyView.scrollEnabled = NO;
    cell.bodyView.editable = NO;
    [cell addSubview:cell.bodyView];
    
    cell.indentationLevel = 0;
    cell.indentationWidth = 10.0;
    
    return cell;
}

+ (instancetype) cellWithPost:(id<HHPostProtocol>)post {
    HHCollapsiblePostCell *cell = [HHCollapsiblePostCell new];
    
    if ([post respondsToSelector:@selector(depth)]) {
        cell.indentationLevel = post.depth;
    }
    
    cell.post = post;
    [cell.headerButton setTitle:post.headerText forState:UIControlStateNormal];
    
    [cell addSubview:cell.bodyView];
    
    return cell;
}

- (void) layoutSubviews {
    CGRect frame = self.frame;
    frame.origin.x = (self.indentationLevel * self.indentationWidth);
    frame.size.width -= frame.origin.x;
    self.frame = frame;
    frame.origin.y = 0;
    
    self.bodyView.frame = frame;
}

- (void) setAttributedText:(NSAttributedString*)text {
    self.bodyView.attributedText = text;
}

- (void) setHeaderText:(NSString*)headerText {
    [self.headerButton setTitle:headerText forState:UIControlStateNormal];
}

- (CGSize) sizeThatFits:(CGSize)size {
    size.width = size.width - (self.indentationLevel * self.indentationWidth);
    self.bodyView.text = self.post.bodyText;
    CGSize textSize = [self.bodyView sizeThatFits:size];
    return textSize;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"HHCollapsiblePostCell: | frame: %@ | depth: %li | text: %@...", NSStringFromCGRect(self.frame), (long)self.indentationLevel, [self.bodyView.text substringToIndex:30]];
}

@end
