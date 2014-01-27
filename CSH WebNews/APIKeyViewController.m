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

@end

@implementation APIKeyViewController {
    UIButton* doneButton;
    UITextField *keyTextField;
    UILabel *descriptionLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"User";
    self.view.backgroundColor = [UIColor whiteColor];
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
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if (newLength == 16 || textField.text.length == 16) {
        doneButton.enabled = YES;
    }
    else {
        doneButton.enabled = NO;
    }
    return (newLength <= 16);
}

- (void) submitAPIKey {
    [[PDKeychainBindings sharedKeychainBindings] setObject:keyTextField.text forKey:kApiKeyKey];
    
    NSString *apiKey = [[PDKeychainBindings sharedKeychainBindings] objectForKey:kApiKeyKey];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *parameters = [NSString stringWithFormat:@"user?api_key=%@&api_agent=iOS", apiKey];
    
    NSString *authenticateString = [NSString stringWithFormat:kBaseURLFormat, parameters];
    
    [WebNewsDataHandler runHTTPOperationWithURL:[NSURL URLWithString:authenticateString] success:^(AFHTTPRequestOperation *op, id responseObject) {
        [self setData:responseObject[@"user"]];
        [self dismissViewControllerAnimated:YES completion:^{
            self.completionBlock();
        }];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        descriptionLabel.text = @"There seems to be an error with that key. Check to see if it's correct and that you're connected to the Internet, and try again.";
        descriptionLabel.textColor = [UIColor redColor];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
