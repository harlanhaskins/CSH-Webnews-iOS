//
//  User.h
//  CSH WebNews
//
//  Created by Harlan Haskins on 9/19/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *realName;
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSDate *updatedAt;
@property (strong, nonatomic) NSDictionary *preferences;

@end
