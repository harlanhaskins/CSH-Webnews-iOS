//
//  HHThreadViewDataSource.h
//  Pods
//
//  Created by Harlan Haskins on 7/20/14.
//
//

@import UIKit;
#import "HHPostCell.h"

static NSString *const kCellIdentifier = @"HHPostCell";

@interface HHThreadViewDataSource : NSObject<UITableViewDataSource, UITableViewDelegate>

+ (instancetype) dataSourceWithPosts:(NSArray*)posts;
- (void) configureCell:(HHPostCell*)cell forIndexPath:(NSIndexPath*)indexPath;
@property (nonatomic) NSArray *posts;
@property (weak, nonatomic) id<HHPostCellDelegate> delegate;

@end
