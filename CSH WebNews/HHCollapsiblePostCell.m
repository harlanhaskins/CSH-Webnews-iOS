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

+ (instancetype) cellWithPost:(id<HHPostProtocol>)post {
    HHCollapsiblePostCell *cell = [HHCollapsiblePostCell new];
    
    [cell setPost:post];
    [cell adjustDepth];
    [cell createTextContainer];
    [cell createHeaderButton];
    
    return cell;
}

- (void) createTextContainer {
    self.bodyView = [UITextView new];
    self.bodyView.scrollEnabled = NO;
    self.bodyView.editable = NO;
    self.bodyView.selectable = NO;
    self.bodyView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.bodyView.opaque = YES;
    self.bodyView.backgroundColor =
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bodyView];
}

- (void) adjustDepth {
    self.indentationLevel = 0;
    self.indentationWidth = 20.0;
    if ([self.post respondsToSelector:@selector(depth)]) {
        self.indentationLevel = self.post.depth;
        [self createLineViews];
    }
}

- (void) createLineViews {
    self.lineViews = [NSMutableArray array];
    for (int i = 1; i < self.indentationLevel; i++) {
        UIView *lineView = [UIView new];
        CGRect lineViewFrame = CGRectMake(0, (i * self.indentationWidth), 1 / [UIScreen mainScreen].scale, 0);
        lineView.frame = lineViewFrame;
        lineView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        [self.lineViews addObject:lineView];
        [self addSubview:lineView];
    }
}

- (void) createHeaderButton {
    self.headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.headerButton.backgroundColor = self.backgroundColor;
    [self.headerButton setTitle:self.post.headerText forState:UIControlStateNormal];
    [self.headerButton setTitleColor:[UIColor colorWithRed:0.0 green:148.0/255.0 blue:224.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.headerButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    self.headerButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.headerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.headerButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5.0, 0, 0);
    self.headerButton.frame = CGRectMake(0, 0, self.frame.size.width, 15.0);
    [self addSubview:self.headerButton];
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

- (void) setText:(NSString*) text {
    self.bodyView.text = text;
}

- (void) setHeaderText:(NSString*)headerText {
    [self.headerButton setTitle:headerText forState:UIControlStateNormal];
}

- (CGSize) sizeThatFits:(CGSize)size {
    size.width = size.width - (self.indentationLevel * self.indentationWidth);
    
    if ([self.post respondsToSelector:@selector(attributedBody)]) {
        self.bodyView.attributedText = self.post.attributedBody;
    }
    else {
        self.bodyView.text = self.post.bodyText;
    }
    
    CGSize textSize = [self.bodyView sizeThatFits:size];
    textSize.height += self.headerButton.height;
    return textSize;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"HHCollapsiblePostCell: | frame: %@ | depth: %li | text: %@...", NSStringFromCGRect(self.frame), (long)self.indentationLevel, [self.bodyView.text substringToIndex:30]];
}

@end
