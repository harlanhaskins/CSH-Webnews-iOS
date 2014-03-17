//
//  ReplyViewController.m
//  CSH News
//
//  Created by Harlan Haskins on 3/12/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "NewPostViewController.h"
#import "HHPostProtocol.h"
#import "UIColor+HHPostCellColors.h"
#import "SAMTextView.h"
#import "SAMTextField.h"
#import "WebNewsDataHandler.h"
#import "SVProgressHUD.h"

@interface NewPostViewController ()

@property (nonatomic) id<HHPostProtocol> post;
@property (nonatomic) UILabel *replyToLabel;
@property (nonatomic) SAMTextField *subjectField;
@property (nonatomic) SAMTextView *bodyTextView;

@property (nonatomic) NSString *newsgroup;

@property (nonatomic, getter = isReply) BOOL reply;

@end

@implementation NewPostViewController

+ (instancetype) replyControllerWithPost:(id<HHPostProtocol>)post {
    NewPostViewController *replyVC = [NewPostViewController new];
    replyVC.post = post;
    replyVC.newsgroup = post.board;
    replyVC.reply = YES;
    return replyVC;
}

+ (instancetype) postControllerWithNewsgroup:(NSString *)string {
    NewPostViewController *replyVC = [NewPostViewController new];
    replyVC.newsgroup = string;
    replyVC.reply = NO;
    return replyVC;
}

- (UILabel*) replyToLabel {
    if (!_replyToLabel) {
        _replyToLabel = [UILabel new];
        _replyToLabel.textColor = [UIColor lightGrayColor];
        _replyToLabel.font = [UIFont fontWithDescriptor:[self fontDescripterForReplyLabel] size:12.0];
        if (self.reply) {
            _replyToLabel.text = [NSString stringWithFormat:@"Reply to %@:\n%@", self.post.headerText, self.post.attributedBody.string];
            _replyToLabel.numberOfLines = 4;
        }
        else {
            _replyToLabel.text = [NSString stringWithFormat:@"New post to %@", self.newsgroup];
            _replyToLabel.numberOfLines = 1;
        }
    }
    return _replyToLabel;
}

- (void) textViewDidChange:(UITextView *)textView {
    CGRect caretRect = [textView caretRectForPosition:textView.endOfDocument];
    [textView scrollRectToVisible:caretRect animated:NO];
}

- (NSString*) randomSubject {
    NSDictionary *subjectsDictionary = @{
                                         @"csh.flame" :             @[@"Hey fuckface!",
                                                                      @"You're a piece of shit, Young Money.",
                                                                      @"I KNOW YOU TOUCHED MY DRUM SET",
                                                                      @"If you touch my drums, I will stab you in the neck with a knife",
                                                                      @"FUCK YOU MOM",
                                                                      @"THIS HOUSE IS A FUCKING PRISON ON PLANET BULLSHIT IN THE GALAXY OF THIS SUCKS CAMEL DICKS",
                                                                      @"THE BUNK BEDS WERE A TERRIBLE IDEA WHY WOULD YOU LET US DO THAT?",
                                                                      @"STEP BROTHERS QUOTES ARE NOT FUNNY!!11!"],
                                         @"csh.noise" :             @[@"Selling sex, $2/lb",
                                                                      @"Has anyone seen Tal?",
                                                                      @"Let's start a band",
                                                                      @"House should adopt a dog",
                                                                      @"House should adopt a cat",
                                                                      @"House should adopt Anthony"],
                                         @"csh.jobs" :              @[@"Treat me like a pirate, and give me that booty."],
                                         @"csh.kudos" :             @[@"Thanks Moffit",
                                                                      @"This drill lubricant is FANTASTIC!",
                                                                      @"Joe showered this week, Thank god.",
                                                                      @"Saucy radiates fatherly love. Thank you"],
                                         @"csh.projects" :          @[@"Are sex robots technical?",
                                                                      @"Presenting Ass-Scratcher 3000"],
                                         @"csh.projects.freshman" : @[@"Guyz, srsly",
                                                                      @"We need more duct-tape."],
                                         @"csh.lists.sysadmin" :    @[@"Shit's broken.",
                                                                      @"Rancor is down."],
                                        };
    
    if (!self.newsgroup || !subjectsDictionary[self.newsgroup]) {
        return @"I have an awesome post.";
    }
    NSArray *subjects = subjectsDictionary[self.newsgroup];
    return subjects[arc4random_uniform((u_int32_t)subjects.count)];
}

- (SAMTextField*) subjectField {
    if (!_subjectField) {
        _subjectField = [SAMTextField new];
        if (self.reply) {
            _subjectField.placeholder = [NSString stringWithFormat:@"Re: %@", self.post.subject];
        }
        else {
            _subjectField.placeholder = [self randomSubject];
        }
        _subjectField.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
        _subjectField.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
        _subjectField.textEdgeInsets = UIEdgeInsetsMake(0.0, [self standardPadding], 0.0, [self standardPadding]);
    }
    return _subjectField;
}

- (SAMTextView*) bodyTextView {
    if (!_bodyTextView) {
        _bodyTextView = [SAMTextView new];
        _bodyTextView.delegate = self;
        _bodyTextView.contentInset = UIEdgeInsetsMake(5.0,
                                                      0.0,
                                                      5.0,
                                                      0.0);
        _bodyTextView.font = [UIFont fontWithDescriptor:[self fontDescripterForBodyText] size:14.0];
        _bodyTextView.placeholder = @"Tap here to start writing...";
    }
    return _bodyTextView;
}

- (CGSize) replyToLabelConstraintSize {
    return CGSizeMake(round(self.view.width * 0.75),
                      CGFLOAT_MAX);
}

- (CGSize) subjectFieldSize {
    return CGSizeMake(self.view.width + (2.0 / [UIScreen mainScreen].scale),
                      44.0);
}

- (CGFloat) subjectFieldBottom {
    return (self.subjectField.bottom + self.subjectField.layer.borderWidth);
}

- (CGSize) bodyTextViewSize {
    return CGSizeMake(self.view.width,
                      self.view.height - [self subjectFieldBottom]);
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.replyToLabel.size = [self.replyToLabel sizeThatFits:[self replyToLabelConstraintSize]];
    [self.replyToLabel centerToParent];
    self.replyToLabel.y = [self topPadding];
    
    self.subjectField.size = [self subjectFieldSize];
    self.subjectField.x = -self.subjectField.layer.borderWidth;
    self.subjectField.y = self.replyToLabel.bottom + [self standardPadding];
    
    self.bodyTextView.size = [self bodyTextViewSize];
    self.bodyTextView.y = [self subjectFieldBottom];
}

- (CGFloat) standardPadding {
    return 15.0;
}

- (CGFloat) topPadding {
    return [self standardPadding] + self.topLayoutGuide.length;
}

- (UIFontDescriptor*) fontDescripterForReplyLabel {
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleCaption1];
    return fontDescriptor;
}

- (UIFontDescriptor*) fontDescripterForBodyText {
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    return fontDescriptor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.replyToLabel];
    [self.view addSubview:self.subjectField];
    [self.view addSubview:self.bodyTextView];
    // Do any additional setup after loading the view.
    if (self.reply) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reply"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(sendReply)];
    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(sendPost)];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    // Take frame with key: UIKeyboardFrameEndUserInfoKey because we want the final frame not the begin one
    NSValue *keyboardFrameValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    
    UIEdgeInsets contentInsets = self.bodyTextView.contentInset;
    contentInsets.bottom = CGRectGetHeight(keyboardFrame);
    
    self.bodyTextView.contentInset = contentInsets;
    self.bodyTextView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = self.bodyTextView.contentInset;
    contentInsets.bottom = 0.0;
    
    self.bodyTextView.contentInset = contentInsets;
    self.bodyTextView.scrollIndicatorInsets = contentInsets;
}

- (void) sendReply {
    
    NSString *baseURL = [NSString stringWithFormat:@"newsgroup=%@&reply_newsgroup=%@&subject=%@&body=%@&reply_number=%ld",
                         self.newsgroup,
                         self.newsgroup,
                         [self subjectText],
                         [self bodyText],
                         (long)self.post.number];
    
    [self sendPostWithBaseURL:baseURL];
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
    if (!body || [body isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"You can't have a blank body."
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Okay.", nil];
        [alertView show];
        return nil;
    }
    return body;
}

- (void) sendPost {
    NSString *baseURL = [NSString stringWithFormat:@"newsgroup=%@&subject=%@&body=%@",
                          self.newsgroup,
                          [self subjectText],
                          [self bodyText]];
    
    [self sendPostWithBaseURL:baseURL];
}

- (void) sendPostWithBaseURL:(NSString*)baseURL {
    [SVProgressHUD showWithStatus:@"Posting..."];
    
    [WebNewsDataHandler runHTTPPOSTOperationWithBaseURL:@"compose"
                                             parameters:baseURL
                                                success:^(AFHTTPRequestOperation *op, id response) {
                                                    if (self.didSendReplyBlock) {
                                                        self.didSendReplyBlock();
                                                    }
                                                    [SVProgressHUD dismiss];
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                }
                                                failure:^(AFHTTPRequestOperation *op, NSError *error) {
                                                    NSLog(@"%s Error: %@", __PRETTY_FUNCTION__, error);
                                                }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
