//
//  ActivityThread.h
//  CSH News
//
//  Created by Harlan Haskins on 1/26/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"

@class NewsgroupThread;

@interface ActivityThread : NSObject<NSCoding, ThreadProtocol>

@property (nonatomic, readonly) Post *parentPost;
@property (nonatomic, readonly) Post *newestPost;
@property (nonatomic, readonly) Post *nextUnreadPost;

@property (nonatomic, readonly) NSUInteger numberOfPosts;
@property (nonatomic, readonly) NSUInteger numberOfUnreadPosts;

@property (nonatomic, readonly) PersonalClass parentPersonalClass;
@property (nonatomic, readonly) PersonalClass highestPriorityPersonalClass;

@property (nonatomic, readonly, getter = isCrossPosted) BOOL crossPosted;

+ (instancetype) activityThreadWithDictionary:(NSDictionary*)dictionary;

@end
