//
//  NSNull+TypeAdditions.h
//  Bryx 911
//
//  Created by Harlan Haskins on 1/25/14.
//  Copyright (c) 2014 Bryx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNull (TypeAdditions)

- (NSInteger) integerValue;

- (int) intValue;

- (BOOL) boolValue;

- (double) doubleValue;

- (float) floatValue;

- (NSUInteger) unsignedIntegerValue;

- (CGFloat) CGFloatValue;

@end
