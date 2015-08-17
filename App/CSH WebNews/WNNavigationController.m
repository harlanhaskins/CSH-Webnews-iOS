//
//  WNNavigationController.m
//  CSH News
//
//  Created by Harlan Haskins on 8/16/15.
//  Copyright © 2015 Haskins. All rights reserved.
//

#import "WNNavigationController.h"

@interface WNNavigationController ()

@end

@implementation WNNavigationController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

@end
