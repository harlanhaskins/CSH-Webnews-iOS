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

@end

@implementation APIKeyViewController {
    UIButton* doneButton;
    UITextField *keyTextField;
    UILabel *descriptionLabel;
}

@synthesize data;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"User";
	UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:34.0f];
    titleLabel.text = @"Enter your\nWebNews API Key";
    titleLabel.numberOfLines = 2;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel sizeToFit];
    [self.view addSubview:titleLabel];
    [titleLabel centerToParent];
    titleLabel.y = 40.0f;
    
    descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.text = @"You can't use Web News until you type in your API key.\nYou can find it in WebNews Settings.";
    descriptionLabel.width = self.view.width * 0.9;
    descriptionLabel.font = [UIFont systemFontOfSize:10.0f];
    descriptionLabel.adjustsFontSizeToFitWidth = YES;
    descriptionLabel.numberOfLines = 2;
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    [descriptionLabel sizeToFit];
    [self.view addSubview:descriptionLabel];
    [descriptionLabel centerToParent];
    descriptionLabel.y = titleLabel.bottom + 7.0f;
    
    keyTextField = [[UITextField alloc] init];
    keyTextField.width = self.view.width * 0.75;
    keyTextField.height = 44.0f;
    keyTextField.placeholder = @"abcd1234efgh5678";
    keyTextField.delegate = self;
    keyTextField.centerY = self.view.centerY;
    keyTextField.centerX = self.view.centerX;
    keyTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    keyTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview:keyTextField];
    [keyTextField becomeFirstResponder];
    
    doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneButton setTitle:@"done" forState:UIControlStateNormal];
    [doneButton setTitle:@"done" forState:UIControlStateDisabled];
    [doneButton addTarget:self action:@selector(submitAPIKey) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTintColor:[UIColor colorWithRed:0.0f green:0.2f blue:1.0f alpha:1.0f]];
    doneButton.enabled = NO;
    [doneButton sizeToFit];
    keyTextField.x -= (doneButton.width / 2);
    doneButton.x = keyTextField.right + 2.0f;
    doneButton.centerY = keyTextField.centerY;
    [self.view addSubview:doneButton];
    
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length + string.length == 16 && ![string isEqualToString:@""]) {
        doneButton.enabled = YES;
        return YES;
    }
    doneButton.enabled = NO;
    return YES;
}

- (void) submitAPIKey {
    [[PDKeychainBindings sharedKeychainBindings] setObject:keyTextField.text forKey:kApiKeyKey];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSLog(@"Loading data...");
    data = [[WebNewsDataHandler sharedHandler] webNewsDataForViewController:self];
    NSLog(@"Data loaded.");
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (!data) {
        descriptionLabel.text = @"There seems to be an error with that key. Check to see if it's correct and that you're connected to the Internet, and try again.";
        descriptionLabel.textColor = [UIColor redColor];
    }
    else {
        [self presentViewController:[AppDelegate viewController] animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
