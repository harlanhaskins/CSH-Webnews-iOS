//
//  ReplyViewController.m
//  CSH News
//
//  Created by Harlan Haskins on 3/12/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "ReplyViewController.h"
#import "HHPostProtocol.h"
#import "UIColor+HHPostCellColors.h"
#import "SAMTextView.h"

@interface ReplyViewController ()

@property (nonatomic) id<HHPostProtocol> post;
@property (nonatomic) UILabel *replyToLabel;
@property (nonatomic) UITextField *subjectField;
@property (nonatomic) SAMTextView *bodyTextView;

@end

@implementation ReplyViewController

+ (instancetype) replyControllerWithPost:(id<HHPostProtocol>)post {
    ReplyViewController *replyVC = [ReplyViewController new];
    replyVC.post = post;
    return replyVC;
}

- (UILabel*) replyToLabel {
    if (!_replyToLabel) {
        _replyToLabel = [UILabel new];
        _replyToLabel.textColor = [UIColor lightGrayColor];
        _replyToLabel.font = [UIFont fontWithDescriptor:[self fontDescripterForReplyLabel] size:14.0];
        _replyToLabel.numberOfLines = 4;
        _replyToLabel.text = [NSString stringWithFormat:@"Reply to %@:\n%@", self.post.headerText, self.post.bodyText];
    }
    return _replyToLabel;
}

- (UITextField*) subjectField {
    if (!_subjectField) {
        _subjectField = [UITextField new];
        _subjectField.placeholder = [NSString stringWithFormat:@"Re: %@", self.post.subject];
        _subjectField.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
        _subjectField.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
        _subjectField.layer.sublayerTransform = CATransform3DMakeTranslation([self standardPadding], 0, 0);
    }
    return _subjectField;
}

- (SAMTextView*) bodyTextView {
    if (!_bodyTextView) {
        _bodyTextView = [SAMTextView new];
        _bodyTextView.contentInset = UIEdgeInsetsMake(5.0,
                                                      5.0,
                                                      5.0,
                                                      5.0);
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
    [self.replyToLabel setSize:[self.replyToLabel sizeThatFits:[self replyToLabelConstraintSize]]];
    [self.replyToLabel centerToParent];
    [self.replyToLabel setY:[self topPadding]];
    
    self.subjectField.size = [self subjectFieldSize];
    [self.subjectField centerToParent];
    self.subjectField.y = self.replyToLabel.bottom + [self standardPadding];
    
    self.bodyTextView.size = [self bodyTextViewSize];
    [self.bodyTextView centerToParent];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
