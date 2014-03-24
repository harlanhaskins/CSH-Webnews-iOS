//
//  ReplyViewController.h
//  CSH News
//
//  Created by Harlan Haskins on 3/12/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HHPostProtocol;

@interface NewPostViewController : UIViewController<UITextViewDelegate>

+ (instancetype) replyControllerWithPost:(id<HHPostProtocol>)post;
+ (instancetype) postControllerWithNewsgroup:(NSString*)string;

@property (nonatomic, copy) void (^didSendReplyBlock)();

@end
