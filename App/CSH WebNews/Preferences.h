//
//  Preferences.h
//  CSH News
//
//  Created by Harlan Haskins on 1/26/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum ThreadMode {
    ThreadModeNormal,
    ThreadModeFlat,
    ThreadModeHybrid
} ThreadMode;

@interface Preferences : NSObject

@property (nonatomic, readonly) ThreadMode threadMode;

@property (nonatomic, readonly) NSTimeZone *timeZone;

@end
