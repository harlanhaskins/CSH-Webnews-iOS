//
//  NewsgroupThreads.m
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "NewsgroupThread.h"
#import "Post.h"

@interface NewsgroupThread ()

@property (nonatomic, readwrite) Post *post;
@property (nonatomic, readwrite) NSInteger depth;
@property (nonatomic, readwrite) NSArray *children;

@end

@implementation NewsgroupThread

+ (instancetype) newsgroupThreadWithDictionary:(NSDictionary*)dictionary atDepth:(NSInteger)depth {
    NewsgroupThread *thread = [NewsgroupThread new];
    thread.post = [Post postwithDictionary:dictionary[@"post"]];
    
    thread.depth = depth;
    
    NSArray *children = dictionary[@"children"];
    thread.children = [thread recursiveChildrenFromDictionaryArray:children atDepth:thread.depth];
    
    return thread;
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
    NewsgroupThreadCell *cell = [[NewsgroupThreadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.thread = thread;
    cell.textLabel.text = cell.thread.post.subject;
    cell.detailTextLabel.text = [cell.thread.post authorshipAndTimeString];
    return cell;
}

@end
