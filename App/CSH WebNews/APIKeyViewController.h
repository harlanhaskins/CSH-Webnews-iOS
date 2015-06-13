//
//  APIKeyViewController.h
//  CSH WebNews
//
//  Created by Harlan Haskins on 9/20/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebNewsDataHandler.h"

@interface APIKeyViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, copy) void (^completionBlock)();

@end
