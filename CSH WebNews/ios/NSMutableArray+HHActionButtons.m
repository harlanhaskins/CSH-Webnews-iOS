//
//  NSMutableArray+HHActionButtons.m
//  CSH News
//
//  Created by Harlan Haskins on 2/4/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "NSMutableArray+HHActionButtons.h"

@implementation NSMutableArray (HHActionButtons)

- (void) HH_addActionButtonWithTitle:(NSString*)title
                              target:(id)target
                            selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    
    [self addObject:button];
}

@end
