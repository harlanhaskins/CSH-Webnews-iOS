//
//  UIColor+CSH.m
//  CSH News
//
//  Created by Harlan Haskins on 9/1/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "UIColor+CSH.h"

@implementation UIColor (CSH)

+ (instancetype) inThreadColor {
    static UIColor *inThreadColor;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
       inThreadColor = [UIColor colorWithRed:0.085 green:0.227 blue:0.709 alpha:1.000];
    });
    return inThreadColor;
}

+ (instancetype) replyColor {
    static UIColor *replyColor;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        replyColor = [UIColor colorWithRed:0.953 green:0.309 blue:0.952 alpha:1.000];
    });
    return replyColor;
}

+ (instancetype) mineColor {
    static UIColor *mineColor;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        mineColor = [UIColor colorWithRed:0.2 green:0.6 blue:0.071 alpha:1.000];
    });
    return mineColor;
}

+ (instancetype) infoColor {
    static UIColor *infoColor;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        infoColor = [UIColor colorWithRed:231.02/55.0 green:62.0/255.0 blue:122.0/255.0 alpha:1.000];
    });
    return infoColor;
}

+ (instancetype) unreadHeaderColor {
    static UIColor *unreadHeaderColor;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        unreadHeaderColor = [UIColor colorWithRed:0.760 green:0.112 blue:0.090 alpha:1.000];
    });
    return unreadHeaderColor;
}

+ (instancetype) indentationColor {
    static UIColor *indentationColor;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        indentationColor = [UIColor colorWithWhite:0.95 alpha:1.000];
    });
    return indentationColor;
}

@end
