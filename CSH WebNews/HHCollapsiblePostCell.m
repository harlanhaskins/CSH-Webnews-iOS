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

@property (nonatomic) NSMutableArray *lineViews;

@end

@implementation HHCollapsiblePostCell

+ (instancetype) new {
    HHCollapsiblePostCell *cell = [[HHCollapsiblePostCell alloc] init];
    
    cell.bodyView = [UITextView new];
    cell.bodyView.scrollEnabled = NO;
    cell.bodyView.editable = NO;
    cell.bodyView.selectable = NO;
    [cell addSubview:cell.bodyView];
    
    cell.indentationLevel = 0;
    cell.indentationWidth = 15.0;
    
    return cell;
}

+ (instancetype) cellWithPost:(id<HHPostProtocol>)post {
    HHCollapsiblePostCell *cell = [HHCollapsiblePostCell new];
    
    if ([post respondsToSelector:@selector(depth)]) {
        cell.indentationLevel = post.depth;
        cell.lineViews = [NSMutableArray array];
        for (int i = 1; i < cell.indentationLevel; i++) {
            UIView *lineView = [UIView new];
            CGRect lineViewFrame = CGRectMake(0, (i * cell.indentationWidth), 1 / [UIScreen mainScreen].scale, 0);
            lineView.frame = lineViewFrame;
            lineView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
            [cell.lineViews addObject:lineView];
            [cell addSubview:lineView];
        }
    }
    
    cell.post = post;
    
    cell.headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cell.headerButton setTitle:post.headerText forState:UIControlStateNormal];
    [cell.headerButton setTitleColor:[UIColor colorWithRed:0.0 green:148.0/255.0 blue:224.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    cell.headerButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    cell.headerButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    cell.headerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    cell.headerButton.frame = CGRectMake(0, 0, cell.frame.size.width, 15.0);
    [cell addSubview:cell.headerButton];
    
    return cell;
}

- (void) layoutSubviews {
    CGFloat buttonHeight = self.headerButton.height;
    
    CGRect frame = self.frame;
    frame.origin.y = buttonHeight;
    frame.origin.x = (self.indentationLevel * self.indentationWidth);
    frame.size.width -= frame.origin.x;
    self.bodyView.frame = frame;
    
    CGRect lineViewFrame = CGRectMake(0, 0, 1 / [UIScreen mainScreen].scale, frame.size.height);
    
    for (int i = 0; i < self.lineViews.count; i++) {
        lineViewFrame.origin.x = (i + 1) * self.indentationWidth;
        [self.lineViews[i] setFrame:lineViewFrame];
    }
    
    frame.size.height = buttonHeight;
    frame.origin.y = 0;
    self.headerButton.frame = frame;
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
    textSize.height += self.headerButton.height;
    return textSize;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"HHCollapsiblePostCell: | frame: %@ | depth: %li | text: %@...", NSStringFromCGRect(self.frame), (long)self.indentationLevel, [self.bodyView.text substringToIndex:30]];
}

@end
