//
//  ActivityTableViewModel.h
//  CSH News
//
//  Created by Harlan Haskins on 1/27/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NewsgroupThread;

@interface ActivityTableViewModel : NSObject<UITableViewDataSource, UITableViewDelegate>

- (void) loadDataWithBlock:(void(^)())block;

@property (nonatomic, copy) void (^didSelectCellBlock)(NewsgroupThread* thread);

@end
