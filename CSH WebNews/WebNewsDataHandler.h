//
//  WebNewsDataHandler.h
//  CSH WebNews
//
//  Created by Harlan Haskins on 9/19/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISO8601DateFormatter.h"

@protocol WebNewsDataHandlerProtocol <NSObject>

@property NSString *title;
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) UIView *view;

@end

@interface WebNewsDataHandler : NSObject <UIAlertViewDelegate>

@property (strong, nonatomic) NSString *baseURL;
- (NSDictionary*) webNewsDataForViewController:(id<WebNewsDataHandlerProtocol>)viewController;
- (NSDictionary*) webNewsDataWithCustomURLPath:(NSString*)path;
+ (instancetype) sharedHandler;
@end
