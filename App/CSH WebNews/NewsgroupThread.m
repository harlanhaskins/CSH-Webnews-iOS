//
//  NewsgroupThreads.m
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "NewsgroupThread.h"
#import "Post.h"
#import "CacheManager.h"
#import "PostCell.h"
#import "UIColor+CSH.h"

@interface NewsgroupThread ()

@property (nonatomic, readwrite) Post *post;
@property (nonatomic, readwrite) NSMutableArray *allThreads;
@property (nonatomic, readwrite) NSMutableArray *allPosts;

@property (nonatomic, readwrite) NSMutableArray *children;

@end

@implementation NewsgroupThread

- (void) encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.post forKey:@"post"];
    [coder encodeObject:@(self.depth) forKey:@"depth"];
    [coder encodeObject:self.children forKey:@"children"];
}

- (id) initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.post = [decoder decodeObjectForKey:@"post"];
        self.depth = [[decoder decodeObjectForKey:@"depth"] integerValue];
        self.children = [decoder decodeObjectForKey:@"children"];
    }
    return self;
}

- (NSUInteger) numberOfPosts {
    return self.allThreads.count;
}

- (NSUInteger) numberOfUnreadPosts {
    NSPredicate *unreadPredicate = [NSPredicate predicateWithFormat:@"%K = %@", @"unread", @YES];
    NSArray *unread = [self.allThreads filteredArrayUsingPredicate:unreadPredicate];
    return unread.count;
}

// Don't expose the recursive methods.
+ (instancetype) newsgroupThreadWithDictionary:(NSDictionary*)dictionary {
    return [self newsgroupThreadWithDictionary:dictionary atDepth:0];
}

+ (instancetype) newsgroupThreadWithDictionary:(NSDictionary*)dictionary atDepth:(NSInteger)depth {
    NewsgroupThread *thread = [NewsgroupThread new];
    thread.post = [Post postwithDictionary:dictionary[@"post"]];
    
    thread.depth = depth;
    
    NSArray *children = dictionary[@"children"];
    thread.children = [thread childrenFromDictionaryArray:children atDepth:thread.depth];
    
    return thread;
}

- (NSMutableArray *) allPosts {
    if (!_allPosts) {
        _allPosts = [self.allThreads valueForKeyPath:@"@unionOfObjects.post"];
    }
    return _allPosts;
}

- (NSMutableArray*) allThreads {
    if (!_allThreads) {
        NSMutableArray *allThreads = [NSMutableArray array];
        [allThreads addObject:self];
        for (NewsgroupThread *thread in self.children) {
            [allThreads addObjectsFromArray:thread.allThreads];
        }
        _allThreads = allThreads;
    }
    return _allThreads;
}

- (BOOL) hasChildren {
    return self.children && self.children.count > 0;
}

- (NSString *) bodyText {
    return self.post.body;
}

- (NSString*) board {
    return self.post.newsgroup;
}

- (NSString*) subject {
    return self.post.subject;
}

- (NSAttributedString *) attributedBody {
    return self.post.attributedBody;
}

- (NSString *)dotsString {
    NSInteger numberPastMax = self.depth - MaxIndentationLevel;
    NSString *dots;
    if (numberPastMax > 0) {
        NSString *paddingString = @"• ";
        dots = [@"" stringByPaddingToLength:(numberPastMax * paddingString.length)
                                 withString:paddingString startingAtIndex:0];
    }
    return dots;
}

- (NSString *)friendlyDate {
    return self.post.friendlyDate;
}

- (NSUInteger) number {
    return self.post.number;
}

- (void) addAttributesToAttributedString:(NSMutableAttributedString*)string {
    [self.post addAttributesToAttributedString:string];
}

- (NSMutableArray *) childrenFromDictionaryArray:(NSArray*)array atDepth:(NSInteger)theDepth {
    NSMutableArray *allChildren = [NSMutableArray array];
    for (NSDictionary *threadDictionary in array) {
        NewsgroupThread *thread = [NewsgroupThread newsgroupThreadWithDictionary:threadDictionary atDepth:(theDepth + 1)];
        [allChildren addObject:thread];
    }
    return allChildren;
}

- (BOOL) isStarred {
    return self.post.isStarred;
}

- (NSComparisonResult) compare:(NewsgroupThread*)thread {
    NSDate *myDate = self.sticky ? self.post.stickyUntilDate : self.post.date;
    NSDate *otherDate = thread.sticky ? thread.post.stickyUntilDate : thread.post.date;
    return [otherDate compare:myDate];
}

- (NSUInteger) hash {
    return @(self.post.number).hash ^ [self.post.newsgroup hash];
}

- (BOOL) isUnread {
    return self.post.unread;
}

- (BOOL) isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    if (self.post.number != [[object post] number]) {
        return NO;
    }
    if (![self.post.newsgroup isEqualToString:[[object post] newsgroup]]) {
        return NO;
    }
    return YES;
}

- (NSString*) description {
    return self.post.description;
}

#pragma mark - ThreadProtocol

- (UIColor*) unreadColor {
    return self.post.unreadColor;
}

- (NSString*) author {
    return self.post.authorName;
}

- (NSDate*) timestamp {
    return self.post.date;
}

- (BOOL) sticky {
    return [self.post isSticky];
}

- (NSString*) newsgroup {
    return nil; // self.post.newsgroup;
}

@end
