//
//  Post.h
//  CSH News
//
//  Created by Harlan Haskins on 1/26/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PersonalClass) {
    PersonalClassMine,
    PersonalClassInThreadWithMine,
    PersonalClassReplyToMine,
    PersonalClassDefault
};

typedef NS_ENUM(NSUInteger, UnreadClass) {
    UnreadClassDefault,
    UnreadClassAuto,
    UnreadClassManual
};

@interface Post : NSObject<NSCoding>

@property (nonatomic, readonly) NSString *newsgroup;
@property (nonatomic, readonly) NSString *parentNewsgroup;
@property (nonatomic, readonly) NSString *followUpNewsgroup;
@property (nonatomic, readonly) NSString *subject;
@property (nonatomic, readonly) NSString *body;
@property (nonatomic, readonly) NSString *htmlBody;
@property (nonatomic, readonly) NSString *headers;
@property (nonatomic, readonly) NSString *authorName;
@property (nonatomic, readonly) NSString *authorEmail;
@property (nonatomic, readonly) NSString *stickyUserName;
@property (nonatomic, readonly) NSString *stickyRealName;

@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSDate *stickyUntilDate;

@property (nonatomic, readonly) NSInteger number;
@property (nonatomic, readonly) NSInteger parentNumber;

@property (nonatomic, readwrite) NSInteger depth;

@property (nonatomic, readonly) PersonalClass personalClass;

@property (nonatomic, readonly) UnreadClass unreadClass;

@property (nonatomic, readonly, getter = isStarred) BOOL starred;
@property (nonatomic, readonly, getter = isOrphaned) BOOL orphaned;
@property (nonatomic, readonly, getter = isStripped) BOOL stripped;
@property (nonatomic, readonly, getter = isReparented) BOOL reparented;
@property (nonatomic, readonly, getter = isUnread) BOOL unread;
@property (nonatomic, readonly, getter = isSelfPost) BOOL selfPost;

@property (nonatomic, readonly) NSString *friendlyDate;
@property (nonatomic, readonly) NSString *authorshipAndTimeString;
@property (nonatomic, readonly) UIColor *subjectColor;

@property (nonatomic, readonly) NSAttributedString *attributedBody;

+ (instancetype) postwithDictionary:(NSDictionary*)postDictionary;
+ (PersonalClass) personalClassFromString:(NSString*)string;
+ (UIColor*) colorForPersonalClass:(PersonalClass)personalClass;

- (void) loadBody;
- (void) loadBodyWithBlock:(void (^)(Post *currentPost))block;

@end
