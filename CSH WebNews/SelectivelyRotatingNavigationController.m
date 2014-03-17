//
//  SelectivelyRotatingNavigationController.m
//  CSH News
//
//  Created by Harlan Haskins on 3/14/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "SelectivelyRotatingNavigationController.h"

@interface SelectivelyRotatingNavigationController ()

@end

@implementation SelectivelyRotatingNavigationController

-(NSUInteger)supportedInterfaceOrientations {
    return self.visibleViewController.supportedInterfaceOrientations;
}

- (BOOL) shouldAutorotate {
    return self.visibleViewController.shouldAutorotate;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.visibleViewController.preferredInterfaceOrientationForPresentation;
}

@end
