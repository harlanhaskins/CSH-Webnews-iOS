//
//  SelectivelyRotatingTabBarController.m
//  CSH News
//
//  Created by Harlan Haskins on 3/14/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "SelectivelyRotatingTabBarController.h"

@interface SelectivelyRotatingTabBarController ()

@end

@implementation SelectivelyRotatingTabBarController

-(NSUInteger)supportedInterfaceOrientations {
    return self.selectedViewController.supportedInterfaceOrientations;
}

- (BOOL) shouldAutorotate {
    return self.selectedViewController.shouldAutorotate;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.selectedViewController.preferredInterfaceOrientationForPresentation;
}

@end
