//
//  NewsgroupThreads.h
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Post;

@interface NewsgroupThread : NSObject<NSCoding, ThreadProtocol>

@property (nonatomic, readonly) Post *post;

@property (nonatomic, readonly) NSMutableArray *allPosts;
@property (nonatomic, readonly) NSMutableArray *allThreads;
@property (nonatomic, readonly, getter=isStarred) BOOL starred;
@property (nonatomic, readonly, getter=isUnread) BOOL unread;
@property (nonatomic) NSUInteger depth;
@property (nonatomic) NSUInteger number;
@property (nonatomic) NSString *body;
@property (nonatomic) NSString *friendlyDate;
@property (nonatomic, readonly) NSString *dotsString;
@property (nonatomic, readonly) NSAttributedString *attributedBody;

+ (instancetype) newsgroupThreadWithDictionary:(NSDictionary*)dictionary;

- (void) addAttributesToAttributedString:(NSMutableAttributedString*)string;

@end