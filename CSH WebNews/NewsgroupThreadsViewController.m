//
//  NewsgroupThreadsViewController.m
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "NewsgroupThreadsViewController.h"
#import "NewsgroupThread.h"

@interface NewsgroupThreadsViewController ()

@property (nonatomic) NSArray *newsgroupThreads;

@end

@implementation NewsgroupThreadsViewController

- (id)initWithNewsgroupThreads:(NSArray*)newsgroupThreads
{
    self = [super init];
    if (self) {
        self.title = @"Newsgroups";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
