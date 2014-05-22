//
//  NewsgroupThreads.h
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HHPostProtocol.h"

@class Post;

@protocol NewsgroupThreadDelegate <NSObject>

- (void) didTapDelete:(id)sender;
- (void) didTapReply:(id)sender;
- (void) didTapStar:(id)sender;

@end

@interface NewsgroupThread : NSObject<NSCoding, HHPostProtocol>

@property (nonatomic, readonly) Post *post;

@property (nonatomic, readonly) NSMutableArray *allPosts;
@property (nonatomic, readonly) NSMutableArray *allThreads;
@property (nonatomic) id<NewsgroupThreadDelegate> delegate;

+ (instancetype) newsgroupThreadWithDictionary:(NSDictionary*)dictionary;
- (UIFont*) fontForSubject;
- (NSString *) subjectAndUnreadCount;

@end