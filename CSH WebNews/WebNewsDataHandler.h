//
//  WebNewsDataHandler.h
//  CSH WebNews
//
//  Created by Harlan Haskins on 9/19/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebNewsDataHandler : NSObject

@property (strong, nonatomic) NSString *baseURL;
- (NSArray*) webNewsDataForPath:(NSString*)path;
+ (instancetype) sharedHandler;
@end
