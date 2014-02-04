//
//  NSNull+TypeAdditions.m
//  Bryx 911
//
//  Created by Harlan Haskins on 1/25/14.
//  Copyright (c) 2014 Bryx. All rights reserved.
//

#import "NSNull+TypeAdditions.h"

@implementation NSNull (TypeAdditions)

- (NSInteger) integerValue {
    return 0;
}

- (NSUInteger) unsignedIntegerValue {
    return 0;
}

- (int) intValue {
    return 0;
}

- (double) doubleValue {
    return 0.0;
}

- (BOOL) boolValue {
    return NO;
}

- (float) floatValue {
    return 0.0;
}

- (CGFloat) CGFloatValue {
    return 0.0;
}

- (NSString*) description {
    return @"";
}

- (NSString*) descriptionWithLocale:(NSLocale*)locale {
    return @"";
}

@end
