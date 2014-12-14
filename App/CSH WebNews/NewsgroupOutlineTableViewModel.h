//
//  NewsgroupTableViewModel.h
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsgroupOutlineTableViewModel : NSObject<UITableViewDataSource>

- (void) loadDataWithBlock:(void(^)())block;

@property (nonatomic) NSArray* newsgroups;

@end
