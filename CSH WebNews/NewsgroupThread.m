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

@interface NewsgroupThread ()

@property (nonatomic, readwrite) Post *post;
@property (nonatomic, readwrite) NSInteger depth;
@property (nonatomic, readwrite) NSArray *children;
@property (nonatomic, readwrite) NSMutableArray *allPosts;

@end

@implementation NewsgroupThread

- (void) encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.post forKey:@"post"];
    [coder encodeObject:@(self.depth) forKey:@"depth"];
    [coder encodeObject:self.children forKey:@"children"];
    [coder encodeObject:self.allPosts forKey:@"allPosts"];
}

- (id) initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.post = [decoder decodeObjectForKey:@"post"];
        self.depth = [[decoder decodeObjectForKey:@"depth"] integerValue];
        self.children = [decoder decodeObjectForKey:@"children"];
        self.allPosts = [decoder decodeObjectForKey:@"allPosts"];
    }
    return self;
}

+ (instancetype) newsgroupThreadWithDictionary:(NSDictionary*)dictionary atDepth:(NSInteger)depth {
    NewsgroupThread *thread = [NewsgroupThread new];
    thread.post = [Post postwithDictionary:dictionary[@"post"]];
    
    thread.depth = depth;
    
    NSArray *children = dictionary[@"children"];
    thread.children = [thread recursiveChildrenFromDictionaryArray:children atDepth:thread.depth];
    
    return thread;
}

- (NSArray*) allPosts {
    if (!_allPosts) {
        _allPosts = [NSMutableArray array];
        [_allPosts addObject:self.post];
        for (NewsgroupThread *thread in self.children) {
            thread.post.depth = thread.depth;
            Post *postToAdd = [CacheManager cachedPostWithNumber:thread.post.number];
            if (!postToAdd || !postToAdd.body || [postToAdd.body isKindOfClass:[NSNull class]]) {
                postToAdd = thread.post;
            }
            [_allPosts addObject:postToAdd];
        }
    }
    return _allPosts;
}

- (UIFont*) fontForSubject {
    for (Post *post in self.allPosts) {
        if (post.unreadClass != UnreadClassDefault) {
            return [UIFont boldSystemFontOfSize:18.0];
        }
    }
    return [UIFont systemFontOfSize:18.0];
}

// Don't expose the recursive methods.
+ (instancetype) newsgroupThreadWithDictionary:(NSDictionary*)dictionary {
    return [self newsgroupThreadWithDictionary:dictionary atDepth:0];
}


- (NSArray *) recursiveChildrenFromDictionaryArray:(NSArray*)array atDepth:(NSInteger)depth {
    NSMutableArray *children = [NSMutableArray array];
    for (NSDictionary *threadDictionary in array) {
        NewsgroupThread *thread = [NewsgroupThread newsgroupThreadWithDictionary:threadDictionary atDepth:(depth + 1)];
        [children addObject:thread];
        [children addObjectsFromArray:thread.children];
    }
    return children;
}

@end

@interface NewsgroupThreadCell ()

@property (nonatomic, readwrite) NewsgroupThread *thread;

@end

@implementation NewsgroupThreadCell

+ (instancetype) cellWithNewsgroupThread:(NewsgroupThread*)thread reuseIdentifier:(NSString*)cellIdentifier {
    NewsgroupThreadCell *cell = [[NewsgroupThreadCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    cell.thread = thread;
    cell.textLabel.text = cell.thread.post.subject;
    cell.textLabel.font = [cell.thread fontForSubject];
    cell.detailTextLabel.text = [cell.thread.post authorshipAndTimeString];
    return cell;
}

@end
