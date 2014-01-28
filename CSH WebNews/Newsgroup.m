//
//  Newsgroup.m
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "Newsgroup.h"
#import "ISO8601DateFormatter.h"

@interface Newsgroup ()

@property (nonatomic, readwrite) NSInteger unreadPosts;

@property (nonatomic, readwrite) PersonalClass highestPriorityPersonalClass;

@property (nonatomic, readwrite) NSString *name;

@property (nonatomic, readwrite) NSDate *newestDate;

@property (nonatomic, readwrite, getter = canAddPost) BOOL postable;

@end

@implementation Newsgroup

- (void) encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:@(self.unreadPosts) forKey:@"unreadPosts"];
    
    [coder encodeObject:@(self.highestPriorityPersonalClass) forKey:@"highestPriorityPersonalClass"];
    
    [coder encodeObject:self.name forKey:@"name"];
    
    [coder encodeObject:self.newestDate forKey:@"newestDate"];
    
    [coder encodeObject:@(self.postable) forKey:@"postable"];
}

- (id) initWithCoder:(NSCoder*)decoder {
    if (self = [super init]) {
        self.unreadPosts = [[decoder decodeObjectForKey:@"unreadPosts"] integerValue];
        
        self.highestPriorityPersonalClass = [[decoder decodeObjectForKey:@"highestPriorityPersonalClass"] integerValue];
        
        self.name = [decoder decodeObjectForKey:@"name"];
        
        self.newestDate = [decoder decodeObjectForKey:@"newestDate"];
        
        self.postable = [[decoder decodeObjectForKey:@"postable"] integerValue];
    }
    return self;
}

+ (instancetype) newsgroupWithDictionary:(NSDictionary*)dictionary {
    Newsgroup *newsgroup = [Newsgroup new];
    
    newsgroup.unreadPosts = [dictionary[@"unread_count"] integerValue];
    
    newsgroup.highestPriorityPersonalClass = [dictionary[@"unread_class"] integerValue];
    
    newsgroup.name = dictionary[@"name"];
    
    ISO8601DateFormatter *formatter = [ISO8601DateFormatter new];
    newsgroup.newestDate = [formatter dateFromString:dictionary[@"newest_date"]];
    
    newsgroup.postable = [dictionary[@"status"] boolValue];
    
    return newsgroup;
}

- (NSString*) textWithUnreadCount {
    if (self.unreadPosts <= 0) {
        return [self name];
    }
    else {
        return [NSString stringWithFormat:@"%@ (%i)", [self name], self.unreadPosts];
    }
}

- (UIFont*) fontForName {
    if (self.unreadPosts > 0) {
        return [UIFont boldSystemFontOfSize:18.0];
    }
    return [UIFont systemFontOfSize:18.0];
}

@end

@interface NewsgroupCell ()

@property (nonatomic, readwrite) Newsgroup *newsgroup;

@end

@implementation NewsgroupCell

+ (instancetype) cellWithNewsgroup:(Newsgroup*)newsgroup {
    
    NewsgroupCell *cell = [[super alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NewsgroupCell"];
    
    cell.newsgroup = newsgroup;
    
    cell.textLabel.text = [cell.newsgroup textWithUnreadCount];
    
    cell.textLabel.font = [newsgroup fontForName];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

@end
