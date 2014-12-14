//
//  ReplyViewController.m
//  CSH News
//
//  Created by Harlan Haskins on 3/12/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "NewPostViewController.h"
#import "SAMTextView.h"
#import "SAMTextField.h"
#import "WebNewsDataHandler.h"

@interface NewPostViewController ()

@property (weak, nonatomic) IBOutlet UILabel *replyToLabel;
@property (weak, nonatomic) IBOutlet SAMTextField *subjectField;
@property (weak, nonatomic) IBOutlet SAMTextView *bodyTextView;
@property (nonatomic) IBOutlet UIBarButtonItem *postButton;

@end

@implementation NewPostViewController

- (IBAction)textFieldDidChange:(UITextField *)sender {
    [self enablePostButtonIfNecessary];
}

- (IBAction) dismiss:(id)sender {
    [self.bodyTextView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) loadDefaultText {
    NSDictionary *parameters = @{@"newsgroup" : self.newsgroup,
                                 @"number" : @(self.post.number)};
    [self showActivityIndicator];
    [[WebNewsDataHandler sharedHandler] GET:@"compose"
                                 parameters:parameters
                                    success:^(NSURLSessionDataTask *task, id responseObject) {
                                        [self hideActivityIndicator];
                                        NSString *replyDefault = responseObject[@"new_post"][@"body"];
                                        if (replyDefault) {
                                            self.bodyTextView.text = [self.bodyTextView.text stringByAppendingString:replyDefault];
                                        }
                                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                        [self hideActivityIndicator];
                                    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bodyTextView.placeholder = @"Tap here to start typing...";
    [self.navigationItem.rightBarButtonItem setTarget:self];
    if (self.reply) {
        self.replyToLabel.text = [NSString stringWithFormat:@"Reply to %@:\n%@", self.post.author, self.post.body];
        self.replyToLabel.numberOfLines = 4;
        self.subjectField.placeholder = [@"Re: " stringByAppendingString:self.post.subject];
        self.navigationItem.rightBarButtonItem.title = @"Reply";
    }
    else {
        self.replyToLabel.text = [NSString stringWithFormat:@"New post to %@", self.newsgroup];
        self.replyToLabel.numberOfLines = 1;
        self.navigationItem.rightBarButtonItem.title = @"Post";
    }
    self.bodyTextView.textContainerInset = (UIEdgeInsets) {
        .top = 10.0,
        .left = 0.0,
        .bottom = 10.0,
        .right = 0.0
    };
    [self enablePostButtonIfNecessary];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.reply) {
        [self loadDefaultText];
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.replyToLabel removeFromSuperview];
}

- (void) sendReply {
    NSDictionary *parameters = @{@"newsgroup": self.newsgroup,
                                 @"reply_newsgroup" : self.newsgroup,
                                 @"subject" : [self subjectText],
                                 @"body" : [self bodyText],
                                 @"reply_number" : @(self.post.number)};
    
    [self sendPostWithParameters:parameters];
}

- (NSString*) subjectText {
    NSString *text = self.subjectField.text;
    if (!text || [text isEqualToString:@""]) {
        text = self.subjectField.placeholder;
    }
    return text;
}

- (NSString*) bodyText {
    NSString *body = self.bodyTextView.text;
    return body;
}

- (void)enablePostButtonIfNecessary {
    self.navigationItem.rightBarButtonItem.enabled = (self.subjectField.text.length > 0) || self.reply;
}

- (void) sendPost {
    NSDictionary *parameters = @{@"newsgroup"   : self.newsgroup,
                                 @"subject"     : [self subjectText],
                                 @"body"        : [self bodyText]};
    
    [self sendPostWithParameters:parameters];
}

- (IBAction) submit {
    if (self.reply) {
        [self sendReply];
    }
    else {
        [self sendPost];
    }
}

- (void)showActivityIndicator {
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
}

- (void)hideActivityIndicator {
    self.navigationItem.rightBarButtonItem = self.postButton;
}

- (void) sendPostWithParameters:(NSDictionary*)parameters {
    [self showActivityIndicator];
    [[WebNewsDataHandler sharedHandler] POST:@"compose"
                                  parameters:parameters
                                     success:^(NSURLSessionDataTask *task, id response) {
                                         NSMutableDictionary *userInfo = @{NewPostViewControllerUserInfoNewsgroupKey :
                                                                               self.newsgroup}.mutableCopy;
                                         if (self.post) {
                                             userInfo[NewPostViewControllerUserInfoPostKey] = self.post;
                                         }
                                         [[NSNotificationCenter defaultCenter] postNotificationName:NewPostViewControllerPostWasSuccessfulNotification
                                                                                             object:self
                                                                                           userInfo:userInfo];
                                         [self hideActivityIndicator];
                                         [self dismiss:nil];
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         [self hideActivityIndicator];
                                     }];
}

@end
