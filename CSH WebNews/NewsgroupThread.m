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
@property (nonatomic, readwrite) NSMutableArray *allThreads;
@property (nonatomic, readwrite) NSMutableArray *allPosts;

@property (nonatomic, readwrite) NSMutableArray *children;

@end

@implementation NewsgroupThread

@synthesize bodyText;
@synthesize headerText;
@synthesize depth;

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

- (NSArray *) allPosts {
    if (!_allPosts) {
        _allPosts = [NSMutableArray array];
        for (NewsgroupThread *thread in self.allThreads) {
            [_allPosts addObject:thread.post];
        }
    }
    return _allPosts;
}

- (NSArray*) allThreads {
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

- (NSString *) bodyText {
    return [self.post.body stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSAttributedString *) attributedBody {
    return self.post.attributedBody;
}

- (NSString*) headerText {
    return self.post.authorName;
}

- (NSMutableArray *) childrenFromDictionaryArray:(NSArray*)array atDepth:(NSInteger)theDepth {
    NSMutableArray *allChildren = [NSMutableArray array];
    for (NSDictionary *threadDictionary in array) {
        NewsgroupThread *thread = [NewsgroupThread newsgroupThreadWithDictionary:threadDictionary atDepth:(theDepth + 1)];
        [allChildren addObject:thread];
    }
    return allChildren;
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
    
    cell.backgroundColor =
    cell.textLabel.backgroundColor =
    cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

@end
