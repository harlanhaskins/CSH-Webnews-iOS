//
//  NewsgroupThreadTableViewController.h
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NewsgroupOutline;

@interface NewsgroupThreadListTableViewModel : NSObject<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) void (^pushViewControllerBlock)(UIViewController* controller);
@property (nonatomic, copy) void (^loadDataBlock)();

+ (instancetype) threadListWithNewsgroupOutline:(NewsgroupOutline*)outline;
- (void) loadData;

@property (nonatomic, readonly) NewsgroupOutline *outline;
@property (nonatomic, readonly) NSArray *threads;

@end
