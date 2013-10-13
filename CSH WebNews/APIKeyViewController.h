//
//  APIKeyViewController.h
//  CSH WebNews
//
//  Created by Harlan Haskins on 9/20/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebNewsDataHandler.h"

@protocol APIKeyDelegate
- (void) loadData;
@end

@interface APIKeyViewController : UIViewController <UITextFieldDelegate, WebNewsDataHandlerProtocol>

@property (strong, nonatomic) id<APIKeyDelegate> delegate;

@end
