//
//  ThreadTableViewModel.h
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThreadDetailTableViewModel : NSObject<UITableViewDataSource, UITableViewDelegate>

+ (instancetype) modelWithPosts:(NSArray*)posts;

@end
