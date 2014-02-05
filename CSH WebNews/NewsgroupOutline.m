//
//  Newsgroup.m
//  CSH News
//
//  Created by Harlan Haskins on 1/28/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "NewsgroupOutline.h"
#import "ISO8601DateFormatter.h"

@interface NewsgroupOutline ()

@property (nonatomic, readwrite) NSInteger unreadPosts;

@property (nonatomic, readwrite) PersonalClass highestPriorityPersonalClass;

@property (nonatomic, readwrite) NSString *name;

@property (nonatomic, readwrite) NSDate *newestDate;

@property (nonatomic, readwrite, getter = canAddPost) BOOL postable;

@end

@implementation NewsgroupOutline

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
        
        self.highestPriorityPersonalClass = [[decoder decodeObjectForKey:@"highestPriorityPersonalClass"] unsignedIntegerValue];
        
        self.name = [decoder decodeObjectForKey:@"name"];
        
        self.newestDate = [decoder decodeObjectForKey:@"newestDate"];
        
        self.postable = [[decoder decodeObjectForKey:@"postable"] integerValue];
    }
    return self;
}

+ (instancetype) newsgroupOutlineWithDictionary:(NSDictionary*)dictionary {
    
    NewsgroupOutline *newsgroup = [NewsgroupOutline new];
    
    newsgroup.unreadPosts = [dictionary[@"unread_count"] integerValue];
    
    newsgroup.highestPriorityPersonalClass = [dictionary[@"unread_class"] unsignedIntegerValue];
    
    newsgroup.name = dictionary[@"name"];
    
    ISO8601DateFormatter *formatter = [ISO8601DateFormatter new];
    newsgroup.newestDate = [formatter dateFromString:dictionary[@"newest_date"]];
    
    newsgroup.postable = [dictionary[@"status"] boolValue];
    
    return newsgroup;
}

- (NSString*) truncatedName {
    return [self.name stringByReplacingOccurrencesOfString:@"csh." withString:@""];
}

- (NSString*) textWithUnreadCount {
    if (self.unreadPosts <= 0) {
        return [self name];
    }
    else {
        return [NSString stringWithFormat:@"%@ (%li)", [self name], (long)self.unreadPosts];
    }
}

- (UIFont*) fontForName {
    if (self.unreadPosts > 0) {
        return [UIFont boldSystemFontOfSize:18.0];
    }
    return [UIFont systemFontOfSize:18.0];
}

@end

@interface NewsgroupOutlineCell ()

@property (nonatomic, readwrite) NewsgroupOutline *newsgroup;

@end

@implementation NewsgroupOutlineCell

+ (instancetype) cellWithNewsgroup:(NewsgroupOutline*)newsgroup {
    
    NewsgroupOutlineCell *cell = [[super alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NewsgroupCell"];
    
    cell.newsgroup = newsgroup;
    
    cell.textLabel.text = [cell.newsgroup textWithUnreadCount];
    
    cell.textLabel.font = [newsgroup fontForName];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

@end
