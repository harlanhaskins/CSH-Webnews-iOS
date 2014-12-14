//
//  Post.m
//  CSH News
//
//  Created by Harlan Haskins on 1/26/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "Post.h"
#import "WebNewsDataHandler.h"
#import "TTTTimeIntervalFormatter.h"
#import "ISO8601DateFormatter.h"
#import "CacheManager.h"
#import "UIColor+CSH.h"

@interface Post ()

@property (nonatomic, readwrite) NSString *newsgroup;
@property (nonatomic, readwrite) NSString *subject;
@property (nonatomic, readwrite) NSString *authorName;
@property (nonatomic, readwrite) NSString *authorEmail;
@property (nonatomic, readwrite) NSString *stickyUserName;
@property (nonatomic, readwrite) NSString *stickyRealName;
@property (nonatomic, readwrite) NSString *parentNewsgroup;
@property (nonatomic, readwrite) NSString *followUpNewsgroup;
@property (nonatomic, readwrite) NSString *body;
@property (nonatomic, readwrite) NSString *htmlBody;
@property (nonatomic, readwrite) NSString *headers;
@property (nonatomic, readwrite) NSAttributedString *attributedBody;

@property (nonatomic, readwrite) UnreadClass unreadClass;

@property (nonatomic, readwrite) NSDate *date;
@property (nonatomic, readwrite) NSDate *stickyUntilDate;

@property (nonatomic, readwrite) NSInteger number;

@property (nonatomic, readwrite) PersonalClass personalClass;

@property (nonatomic, readwrite, getter = isOrphaned) BOOL orphaned;
@property (nonatomic, readwrite, getter = isStripped) BOOL stripped;
@property (nonatomic, readwrite, getter = isReparented) BOOL reparented;

@end

@implementation Post

static NSDateFormatter *dateFormatter;
static ISO8601DateFormatter *iso8601DateFormatter;
static TTTTimeIntervalFormatter *timeFormatter;

+ (void) initialize {
    dateFormatter = [NSDateFormatter new];
    iso8601DateFormatter = [ISO8601DateFormatter new];
    timeFormatter = [TTTTimeIntervalFormatter new];
    timeFormatter.usesIdiomaticDeicticExpressions = YES;
}

- (void) encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.newsgroup forKey:@"newsgroup"];
    [coder encodeObject:self.subject forKey:@"subject"];
    [coder encodeObject:self.authorName forKey:@"authorName"];
    [coder encodeObject:self.authorEmail forKey:@"authorEmail"];
    [coder encodeObject:self.stickyUserName forKey:@"stickyUserName"];
    [coder encodeObject:self.stickyRealName forKey:@"stickyRealName"];
    [coder encodeObject:self.parentNewsgroup forKey:@"parentNewsgroup"];
    [coder encodeObject:self.followUpNewsgroup forKey:@"followUpNewsgroup"];
    [coder encodeObject:self.body forKey:@"body"];
    [coder encodeObject:self.headers forKey:@"headers"];
    [coder encodeObject:self.attributedBody forKey:@"attributedBody"];
    
    [coder encodeObject:self.date forKey:@"date"];
    [coder encodeObject:self.stickyUntilDate forKey:@"stickyUntilDate"];
    
    [coder encodeObject:@(self.number) forKey:@"number"];
    
    [coder encodeObject:@(self.personalClass) forKey:@"personalClass"];
    
    [coder encodeObject:@(self.starred) forKey:@"starred"];
    [coder encodeObject:@(self.orphaned) forKey:@"orphaned"];
    [coder encodeObject:@(self.stripped) forKey:@"stripped"];
    [coder encodeObject:@(self.reparented) forKey:@"reparented"];
    
    [coder encodeObject:@(self.unreadClass) forKey:@"unreadClass"];
}

- (id) initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.newsgroup = [decoder decodeObjectForKey:@"newsgroup"];
        self.subject = [decoder decodeObjectForKey:@"subject"];
        self.authorName = [decoder decodeObjectForKey:@"authorName"];
        self.authorEmail = [decoder decodeObjectForKey:@"authorEmail"];
        self.stickyUserName = [decoder decodeObjectForKey:@"stickyUserName"];
        self.stickyRealName = [decoder decodeObjectForKey:@"stickyRealName"];
        self.parentNewsgroup = [decoder decodeObjectForKey:@"parentNewsgroup"];
        self.followUpNewsgroup = [decoder decodeObjectForKey:@"followUpNewsgroup"];
        [self setBody:[decoder decodeObjectForKey:@"body"] processed:NO];
        self.attributedBody = [decoder decodeObjectForKey:@"attributedBody"];
        self.headers = [decoder decodeObjectForKey:@"headers"];
        
        self.date = [decoder decodeObjectForKey:@"date"];
        self.stickyUntilDate = [decoder decodeObjectForKey:@"stickyUntilDate"];
        
        self.number = [[decoder decodeObjectForKey:@"number"] integerValue];
        
        self.personalClass = [[decoder decodeObjectForKey:@"personalClass"] integerValue];
        
        self.starred = [[decoder decodeObjectForKey:@"starred"] boolValue];
        self.orphaned = [[decoder decodeObjectForKey:@"orphaned"] boolValue];
        self.stripped = [[decoder decodeObjectForKey:@"stripped"] boolValue];
        self.reparented = [[decoder decodeObjectForKey:@"reparented"] boolValue];
        self.unreadClass = [[decoder decodeObjectForKey:@"unreadClass"] integerValue];
    }
    return self;
}

+ (instancetype) postwithDictionary:(NSDictionary*)postDictionary {
    
    if (!postDictionary) return nil;
    
    NSInteger postNumber = [postDictionary[@"number"] integerValue];
    NSString *newsgroup  = postDictionary[@"newsgroup"];
    
    Post *post = [CacheManager cachedPostWithNewsgroup:newsgroup number:postNumber];
    if (post) {
        // Change the values that can change.
        post.starred = [postDictionary[@"starred"] boolValue];
        post.unreadClass = [self unreadClassFromString:postDictionary[@"unread_class"]];
        post.stickyUntilDate = [iso8601DateFormatter dateFromString:postDictionary[@"sticky_until"]];
        return post;
    }
    
    post = [Post new];
    post.newsgroup = newsgroup;
    post.subject = postDictionary[@"subject"];
    post.authorName = postDictionary[@"author_name"];
    post.authorEmail = postDictionary[@"author_email"];
    
    post.date = [iso8601DateFormatter dateFromString:postDictionary[@"date"]];
    
    post.number = postNumber;
    
    post.personalClass = [self personalClassFromString:postDictionary[@"personal_class"]];
    
    post.body = postDictionary[@"body"];
    
    post.headers = postDictionary[@"headers"];
    
    post.stripped = [postDictionary[@"stripped"] boolValue];
    
    post.orphaned = [postDictionary[@"orphaned"] boolValue];
    
    post.reparented = [postDictionary[@"reparented"] boolValue];
    
    post.starred = [postDictionary[@"starred"] boolValue];
    
    NSDictionary *stickyUser = postDictionary[@"sticky_user"];
    post.stickyUserName = stickyUser[@"username"];
    post.stickyRealName = stickyUser[@"real_name"];
    post.stickyUntilDate = [iso8601DateFormatter dateFromString:postDictionary[@"sticky_until"]];
    
    post.unreadClass = [self unreadClassFromString:postDictionary[@"unread_class"]];
    
    return post;
}

+ (PersonalClass) personalClassFromString:(NSString*)string {
    if ([string isEqualToString:@"mine_reply"]) {
        return PersonalClassReplyToMine;
    }
    if ([string isEqualToString:@"mine_in_thread"]) {
        return PersonalClassInThreadWithMine;
    }
    if ([string isEqualToString:@"mine"]) {
        return PersonalClassMine;
    }
    return PersonalClassDefault;
}

+ (UnreadClass) unreadClassFromString:(NSString*)string {
    if ([string isEqualToString:@"auto"]) {
        return UnreadClassAuto;
    }
    if ([string isEqualToString:@"manual"]) {
        return UnreadClassManual;
    }
    return UnreadClassDefault;
}

- (void) loadBody {
    [self loadBodyWithCompletion:nil];
}

- (BOOL) isSticky {
    return [self.stickyUntilDate timeIntervalSinceDate:[NSDate date]] > 0;
}

- (void) loadBodyWithCompletion:(void (^)(NSError *error))completion {
    
    if (self.body && completion) {
        completion(nil);
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%@", self.newsgroup, @(self.number)];
    
    [[WebNewsDataHandler sharedHandler] GET:url
                                 parameters:nil
                                    success:^(NSURLSessionDataTask *task, id response) {
                                        dispatch_queue_t queue = dispatch_queue_create(url.UTF8String, DISPATCH_QUEUE_CONCURRENT);
                                        dispatch_async(queue, ^{
                                            [self setBody:response[@"post"][@"body"] processed:YES];
                                            [CacheManager cachePost:self];
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                if (completion) completion(nil);
                                            });
                                        });
                                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                        NSLog(@"Error: %@", error);
                                        if (completion) completion(error);
                                    }];
}

- (NSString*) dateString {
    // Create an empty formatter.
    
    // Set the date format to a nice format.
    [dateFormatter setDateFormat:@"yyyy-MM-d"];
    
    // Create the subtitle from those components.
    return [dateFormatter stringFromDate:self.date];
}

- (NSString *) timeString {
    // Set the date format to a nice format.
    [dateFormatter setDateFormat:@"hh:mm:sa"];
    
    // Create the subtitle from those components.
    return [dateFormatter stringFromDate:self.date];
}



- (NSString*) friendlyDate {
    
//    NSString *time = [self timeString];
//    NSString *date = [self dateString];
//    NSString *friendlyString = [NSString stringWithFormat:@"%@ %@", date, time];
    NSString *friendlyString = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:self.date];
    return friendlyString;
}

- (UIColor*) unreadColor {
    return self.unread ? [[self class] colorForPersonalClass:self.personalClass] : nil;
}

+ (UIColor*) colorForPersonalClass:(PersonalClass)personalClass {
    switch (personalClass) {
        case PersonalClassInThreadWithMine:
            return [UIColor inThreadColor];
            
        case PersonalClassMine:
            return [UIColor mineColor];
            
        case PersonalClassReplyToMine:
            return [UIColor replyColor];
            
        default:
            return [UIColor colorWithWhite:0.29 alpha:1.0];
    }
}

- (BOOL) isUnread {
    return self.unreadClass != UnreadClassDefault;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"Depth: %@", @(self.depth)];
}

- (void) setBody:(NSString *)body processed:(BOOL)processed {
    _body = body;
    if (processed) {
        _attributedBody = [self createAttributedBody];
    }
}

- (NSAttributedString *) createAttributedBody {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.body];
    [self addAttributesToAttributedString:attributedString];
    return attributedString;
}

- (void) addAttributesToAttributedString:(NSMutableAttributedString*)string {
    NSRange wholeStringRange = NSMakeRange(0, string.length);

    NSString *lineIsQuoteRegex = @"^>.*$"; // Will match any line that begins with `>`.
    NSShadow *shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0, 1);
    shadow.shadowColor = [UIColor whiteColor];
    NSDictionary *defaultAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"CriqueGrotesk" size:15.0],
                                        NSShadowAttributeName : shadow};
    [string addAttributes:defaultAttributes range:wholeStringRange];
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:lineIsQuoteRegex
                                                                           options:NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor lightGrayColor]};
    [regex enumerateMatchesInString:string.string
                            options:0
                              range:wholeStringRange
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                             [string addAttributes:attributes range:match.range];
                         }];
}

- (BOOL) isSelfPost {
    return self.personalClass == PersonalClassMine;
}

@end
