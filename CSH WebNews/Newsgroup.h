//
//  Newsgroup.h
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"

@interface Newsgroup : NSObject<NSCoding>

@property (nonatomic, readonly) NSInteger unreadPosts;

@property (nonatomic, readonly) PersonalClass highestPriorityPersonalClass;

@property (nonatomic, readonly) NSString *name;

@property (nonatomic, readonly) NSDate *newestDate;

@property (nonatomic, readonly, getter = canAddPost) BOOL postable;

+ (instancetype) newsgroupWithDictionary:(NSDictionary*)dictionary;

@end

@interface NewsgroupCell : UITableViewCell

@property (nonatomic, readonly) Newsgroup *newsgroup;

+ (instancetype) cellWithNewsgroup:(Newsgroup*)newsgroup;

@end
