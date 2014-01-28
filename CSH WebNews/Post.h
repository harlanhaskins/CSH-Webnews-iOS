//
//  Post.h
//  CSH News
//
//  Created by Harlan Haskins on 1/26/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum PersonalClass {
    PersonalClassMine,
    PersonalClassInThreadWithMine,
    PersonalClassReplyToMine,
    PersonalClassDefault
} PersonalClass;

typedef enum UnreadClass {
    UnreadClassDefault,
    UnreadClassAuto,
    UnreadClassManual
} UnreadClass;

@interface Post : NSObject<NSCoding>

@property (nonatomic, readonly) NSString *newsgroup;
@property (nonatomic, readonly) NSString *parentNewsgroup;
@property (nonatomic, readonly) NSString *followUpNewsgroup;
@property (nonatomic, readonly) NSString *subject;
@property (nonatomic, readonly) NSString *body;
@property (nonatomic, readonly) NSString *headers;
@property (nonatomic, readonly) NSString *authorName;
@property (nonatomic, readonly) NSString *authorEmail;
@property (nonatomic, readonly) NSString *stickyUserName;
@property (nonatomic, readonly) NSString *stickyRealName;

@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSDate *stickyUntilDate;

@property (nonatomic, readonly) NSInteger number;
@property (nonatomic, readonly) NSInteger parentNumber;

@property (nonatomic, readonly) PersonalClass personalClass;

@property (nonatomic, readonly, getter = isStarred) BOOL starred;
@property (nonatomic, readonly, getter = isOrphaned) BOOL orphaned;
@property (nonatomic, readonly, getter = isStripped) BOOL stripped;
@property (nonatomic, readonly, getter = isReparented) BOOL reparented;

- (NSString*) friendlyDate;
- (NSString *) authorshipAndTimeString;
- (UIColor*) subjectColor;

+ (instancetype) postwithDictionary:(NSDictionary*)postDictionary;
+ (PersonalClass) personalClassFromString:(NSString*)string;

@end

@interface PostCell : UITableViewCell

@property (nonatomic, readonly) Post *post;
+ (NSString*) cellIdentifier;

@end
