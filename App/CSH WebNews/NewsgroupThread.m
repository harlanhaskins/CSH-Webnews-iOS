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
#import "NSMutableArray+HHActionButtons.h"

@interface NewsgroupThread ()

@property (nonatomic, readwrite) Post *post;
@property (nonatomic, readwrite) NSMutableArray *allThreads;
@property (nonatomic, readwrite) NSMutableArray *allPosts;

@property (nonatomic, readwrite) NSMutableArray *children;

@end

@implementation NewsgroupThread

@synthesize bodyText;
@synthesize headerText;
@synthesize depth;
@synthesize actionButtons = _actionButtons;

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

- (UIFont*) fontForSubject {
    for (Post *post in self.allPosts) {
        if (post.unreadClass != UnreadClassDefault) {
            return [UIFont boldSystemFontOfSize:18.0];
        }
    }
    return [UIFont systemFontOfSize:18.0];
}

- (NSMutableArray *) allPosts {
    if (!_allPosts) {
        _allPosts = [NSMutableArray array];
        for (NewsgroupThread *thread in self.allThreads) {
            [_allPosts addObject:thread.post];
        }
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

- (NSMutableArray*) actionButtons {
    if (!_actionButtons) {
        _actionButtons = [NSMutableArray new];
        [_actionButtons HH_addActionButtonWithImage:[UIImage imageNamed:@"Reply"]
                                             target:self.delegate
                                           selector:@selector(didTapReply:)];
        
        UIImage *starImage = [self isStarred] ? [UIImage imageNamed:@"StarFilled"] : [UIImage imageNamed:@"Star"];
        [_actionButtons HH_addActionButtonWithImage:starImage
                                             target:self.delegate
                                           selector:@selector(didTapStar:)];
    }
    return _actionButtons;
}

- (BOOL) hasChildren {
    return self.children && self.children.count > 0;
}

- (NSString *) bodyText {
    return [self.post.body stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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

- (NSString*) headerText {
    return [NSString stringWithFormat:@"%@ (%@)", self.post.authorName, [self.post friendlyDate]];
}

- (NSInteger) number {
    return self.post.number;
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
    return [self.post.date compare:thread.post.date];
}

- (NSUInteger) hash {
    return self.post.number * [self.post.newsgroup hash];
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

@end
