//
//  Preferences.m
//  CSH News
//
//  Created by Harlan Haskins on 1/26/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "Preferences.h"

@interface Preferences ()

@property (nonatomic, readwrite) ThreadMode threadMode;

@property (nonatomic, readwrite) NSTimeZone *timeZone;

@end

@implementation Preferences

+ (instancetype) preferencesFromDictionary:(NSDictionary*)preferencesDictionary {
    Preferences *preferences = [Preferences new];
    NSString *timeZone = preferencesDictionary[@"time_zone"];
    NSArray *timeZoneComponents = [timeZone componentsSeparatedByString:@" "];
    preferences.timeZone = [NSTimeZone timeZoneWithName:timeZoneComponents[0]];
    return preferences;
}

@end
