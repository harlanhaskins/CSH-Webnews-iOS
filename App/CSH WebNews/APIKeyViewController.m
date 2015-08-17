//
//  APIKeyViewController.m
//  CSH WebNews
//
//  Created by Harlan Haskins on 9/20/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import "AppDelegate.h"
#import "APIKeyViewController.h"

@interface APIKeyViewController ()

@property (nonatomic) NSDictionary *data;

@property (weak, nonatomic) IBOutlet UITextField *keyTextField;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic) UIStatusBarStyle oldStyle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyFieldTrailingConstraint;

@end

@implementation APIKeyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"User";

    self.oldStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    [self.keyTextField becomeFirstResponder];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *acceptableCharacters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:acceptableCharacters] invertedSet];
    
    return (newLength <= 16) && [string rangeOfCharacterFromSet:cs].location == NSNotFound;
}

- (void) submitAPIKey {
    [AuthenticationManager setApiKey:self.keyTextField.text];
    [self.activityIndicator startAnimating];
    [self setKeyFieldLeadingConstant:10.0];
    NSString *url = @"user";
    
    [[WebNewsDataHandler sharedHandler] GET:url parameters:nil
                                    success:^(NSURLSessionDataTask *task, id responseObject) {
        [self setData:responseObject[@"user"]];
        [UIApplication sharedApplication].statusBarStyle = self.oldStyle;
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.completionBlock) {
                self.completionBlock();
            }
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        self.descriptionLabel.text = @"There seems to be an error with that key.\n"
                                     @"Check it and your connection.";
        self.descriptionLabel.textColor = [UIColor redColor];
        [self.activityIndicator stopAnimating];
        [self setKeyFieldLeadingConstant:-20.0];
        [AuthenticationManager invalidateKey];
    }];
}

- (void) setKeyFieldLeadingConstant:(CGFloat)constant {
    self.keyFieldTrailingConstraint.constant = constant;
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         [self.view layoutIfNeeded];
                     } completion:nil];
}

- (void) dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self.keyTextField resignFirstResponder];
    [super dismissViewControllerAnimated:flag completion:completion];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL shouldReturn = (textField.text.length == 16);
    if (shouldReturn) {
        [self submitAPIKey];
    }
    return shouldReturn;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
