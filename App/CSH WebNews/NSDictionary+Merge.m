//
//  NSDictionary+Merge.m
//  CSH WebNews
//
//  Created by Harlan Haskins on 10/14/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import "NSDictionary+Merge.h"

@implementation NSDictionary (Merge)

+ (NSDictionary *) dictionaryByMerging: (NSDictionary *) dict1 with: (NSDictionary *) dict2 {
    NSMutableDictionary * result = [NSMutableDictionary dictionaryWithDictionary:dict1];
    
    [dict2 enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        if (!dict1[key]) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary * newVal = [dict1[key] dictionaryByMergingWith: (NSDictionary *) obj];
                result[key] = newVal;
            } else {
                result[key] = obj;
            }
        }
    }];
    
    return (NSDictionary *)[result mutableCopy];
}

- (NSDictionary *) dictionaryByMergingWith: (NSDictionary *) dict {
    return [[self class] dictionaryByMerging: self with: dict];
}

@end
