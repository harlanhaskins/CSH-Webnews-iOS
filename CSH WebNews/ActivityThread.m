//
//  ActivityThread.m
//  CSH News
//
//  Created by Harlan Haskins on 1/26/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "ActivityThread.h"
#import "Post.h"

@interface ActivityThread ()

@property (nonatomic, readwrite) Post *parentPost;
@property (nonatomic, readwrite) Post *newestPost;
@property (nonatomic, readwrite) Post *nextUnreadPost;

@property (nonatomic, readwrite) NSInteger numberOfPosts;
@property (nonatomic, readwrite) NSInteger numberOfUnreadPosts;

@property (nonatomic, readwrite) PersonalClass parentPersonalClass;
@property (nonatomic, readwrite) PersonalClass highestPriorityPersonalClass;

@property (nonatomic, readwrite, getter = isCrossPosted) BOOL crossPosted;

@end

@implementation ActivityThread

+ (instancetype) activityThreadWithDictionary:(NSDictionary*)dictionary {
    ActivityThread *thread = [ActivityThread new];
    thread.parentPost = [Post postwithDictionary:dictionary[@"thread_parent"]];
    thread.newestPost = [Post postwithDictionary:dictionary[@"newest_post"]];
    thread.nextUnreadPost = [Post postwithDictionary:dictionary[@"next_unread"]];
    
    thread.numberOfPosts = [dictionary[@"post_count"] integerValue];
    thread.numberOfUnreadPosts = [dictionary[@"unread_count"] integerValue];
    
    thread.parentPersonalClass = [Post personalClassFromString:dictionary[@"personal_class"]];
    thread.highestPriorityPersonalClass = [Post personalClassFromString:dictionary[@"unread_class"]];
    
    thread.crossPosted = [dictionary[@"cross_posted"] boolValue];
    
    return thread;
}

@end
