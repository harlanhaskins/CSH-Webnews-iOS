//
//  ActivityThread.m
//  CSH News
//
//  Created by Harlan Haskins on 1/26/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "ActivityThread.h"
#import "Post.h"
#import "NewsgroupThread.h"
#import "WebNewsDataHandler.h"

@interface ActivityThread ()

@property (nonatomic, readwrite) Post *parentPost;
@property (nonatomic, readwrite) Post *newestPost;
@property (nonatomic, readwrite) Post *nextUnreadPost;

@property (nonatomic, readwrite) NSUInteger numberOfPosts;
@property (nonatomic, readwrite) NSUInteger numberOfUnreadPosts;

@property (nonatomic, readwrite) PersonalClass parentPersonalClass;
@property (nonatomic, readwrite) PersonalClass highestPriorityPersonalClass;

@property (nonatomic, readwrite, getter = isCrossPosted) BOOL crossPosted;

@end

@implementation ActivityThread

@synthesize sticky = _sticky;

- (void) encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.parentPost forKey:@"parentPost"];
    [coder encodeObject:self.newestPost forKey:@"newestPost"];
    [coder encodeObject:self.nextUnreadPost forKey:@"nextUnreadPost"];
    
    [coder encodeObject:@(self.numberOfPosts) forKey:@"numberOfPosts"];
    [coder encodeObject:@(self.numberOfUnreadPosts) forKey:@"numberOfUnreadPosts"];
    
    [coder encodeObject:@(self.parentPersonalClass) forKey:@"parentPersonalClass"];
    [coder encodeObject:@(self.highestPriorityPersonalClass) forKey:@"highestPriorityPersonalClass"];
    
    [coder encodeObject:@(self.crossPosted) forKey:@"crossPosted"];
}

- (instancetype) initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.parentPost = [decoder decodeObjectForKey:@"parentPost"];
        self.newestPost = [decoder decodeObjectForKey:@"newestPost"];
        self.nextUnreadPost = [decoder decodeObjectForKey:@"nextUnreadPost"];
        
        self.numberOfPosts = [[decoder decodeObjectForKey:@"numberOfPosts"] integerValue];
        self.numberOfUnreadPosts = [[decoder decodeObjectForKey:@"numberOfUnreadPosts"] integerValue];
        
        self.parentPersonalClass = [[decoder decodeObjectForKey:@"parentPersonalClass"] integerValue];
        self.highestPriorityPersonalClass = [[decoder decodeObjectForKey:@"highestPriorityPersonalClass"] integerValue];
        
        self.crossPosted = [[decoder decodeObjectForKey:@"crossPosted"] boolValue];
    }
    return self;
}

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

- (NSString*) debugDescription {
    return [self description];
}

- (NSString*) description {
    return [[self parentPost] subject];
}

#pragma mark - ThreadProtocol

- (NSString*) subject {
    return self.parentPost.subject;
}

- (UIColor*) unreadColor {
    return self.numberOfUnreadPosts > 0 ? [Post colorForPersonalClass:self.highestPriorityPersonalClass] : nil;
}

- (NSString*) author {
    return self.parentPost.authorName;
}

- (NSDate*) timestamp {
    return self.parentPost.date;
}

- (BOOL) sticky {
    return !![self.parentPost isSticky];
}

- (NSString*) newsgroup {
    return self.parentPost.newsgroup;
}

@end
