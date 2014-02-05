//
//  CellActionsView.m
//  CSH News
//
//  Created by Harlan Haskins on 2/4/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "HHCellActionsView.h"

@interface HHCellActionsView ()

@property (nonatomic) NSArray *actionButtons;

@end

@implementation HHCellActionsView

+ (instancetype) viewWithActionButtons:(NSArray*)actionButtons {
    HHCellActionsView *view = [[HHCellActionsView alloc] init];
    view.actionButtons = actionButtons;
    for (UIButton *button in view.actionButtons) {
        [view addSubview:button];
    }
    return view;
}

- (void) layoutSubviews {
    NSUInteger numberOfButtons = self.actionButtons.count;
    if (numberOfButtons == 0) {
        return;
    }
    
    // Quick math. Center the buttons based on dividing this view by numberOfButtons + 1. It's cool.
    CGFloat buttonCenterX = self.frame.size.width / (numberOfButtons + 1);
    CGFloat buttonCenterY = self.frame.size.height / 2;
    
    for (int i = 0; i < numberOfButtons; ++i) {
        UIButton *button = self.actionButtons[i];
        button.center = CGPointMake(buttonCenterX * (i + 1), buttonCenterY);
        
        CGRect frame = button.frame;
        frame.size = CGSizeMake(buttonCenterX, buttonCenterX);
        button.frame = frame;
    }
}

@end
