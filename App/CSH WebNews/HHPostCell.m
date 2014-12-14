//
//  HHPostCell.m
//  CSH News
//
//  Created by Harlan Haskins on 2/4/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "HHPostCell.h"
#import "UIColor+CSH.h"
#import "NewsgroupThread.h"

@interface HHPostCell ()

@property (nonatomic) BOOL actionButtonsVisible;

@property (weak, nonatomic) IBOutlet UILabel *dotLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextView *bodyView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *starButton;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;

@property (nonatomic) NSString *headerText;

@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *headerIndentationConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starButtonHeightConstraint;

@property (nonatomic) CGFloat textViewHeight;

@end

static UIImage *starImage;
static UIImage *filledStarImage;
static NSMutableDictionary *memoizedColors;

static CGFloat const IndentationColorStartingValue = 0.95;

@implementation HHPostCell

+ (void) initialize {
    starImage = [UIImage imageNamed:@"Star"];
    filledStarImage = [UIImage imageNamed:@"StarFilled"];
    memoizedColors = [NSMutableDictionary dictionary];
}

- (void) drawIndentationLines {
    NSPredicate *shapeLayerPredicate = [NSPredicate predicateWithFormat:@"class == %@", [CAShapeLayer class]];
    NSArray *shapeLayers = [self.layer.sublayers filteredArrayUsingPredicate:shapeLayerPredicate];
    [shapeLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    for (int i = 0; i < self.indentationLevel; i++) {
        CAShapeLayer *line = [[CAShapeLayer alloc] init];
        UIBezierPath *drawPath = [UIBezierPath bezierPathWithRect:(CGRect) {
            {.x = ((i + 1) * self.indentationWidth) - (self.indentationWidth * 0.25),
             .y = 0},
            {.width = 1.0,
             .height = self.frame.size.height}
        }];
        UIColor *fillColor = memoizedColors[@(i)];
        if (!fillColor) {
            // Magic numbers out the wazoo. That's the price for pleasing colors!
            fillColor = [UIColor colorWithWhite:IndentationColorStartingValue
                                          alpha:1.0];
            memoizedColors[@(i)] = fillColor;
        }
        line.fillColor = fillColor.CGColor;
        line.path = drawPath.CGPath;
        [self.layer addSublayer:line];
    }
}

- (void) setIndentationLevel:(NSInteger)indentationLevel {
    [super setIndentationLevel:MIN(MaxIndentationLevel, indentationLevel)];
    [self indentToWidth:(self.indentationWidth * self.indentationLevel)];
}

- (void) setIndentationWidth:(CGFloat)indentationWidth {
    [super setIndentationWidth:indentationWidth];
    [self indentToWidth:(self.indentationWidth * self.indentationLevel)];
}

- (void) indentToWidth:(CGFloat)width {
    width += 7.0;
    self.headerIndentationConstraint.constant = width;
}

- (void) initializeHeaderLabel {
    self.headerLabel.text = self.post.author;
    self.dotLabel.text = self.post.dotsString;
    self.timeLabel.text = self.post.friendlyDate;
    UIColor *labelColor = [UIColor darkGrayColor];
    if (self.post.unread) {
        labelColor = [UIColor infoColor];
    }
    self.headerLabel.textColor = self.dotLabel.textColor = self.timeLabel.textColor = labelColor;
}

- (void) initializePostBody {
    self.bodyView.attributedText = self.post.attributedBody;
    self.subjectLabel.text = self.post.subject;
}

- (void) prepareForReuse {
    _post = nil; // Don't use the setter.
}

- (void) setAttributedText:(NSAttributedString*)text {
    self.bodyView.attributedText = text;
}

- (void) setText:(NSString*) text {
    self.bodyView.text = text;
}

- (void) setTag:(NSInteger)tag {
    [super setTag:tag];
    self.replyButton.tag = tag;
    self.starButton.tag = tag;
}

- (IBAction)didTapReply:(id)sender {
    [self.delegate postCellDidTapReply:self];
}

- (IBAction)didTapStar:(id)sender {
    [self.delegate postCellDidTapStar:self];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    [self drawIndentationLines];
}

- (void) setPost:(NewsgroupThread *)post {
    _post = post;
    [self initializeHeaderLabel];
    [self initializePostBody];
    [self setStarFilling];
}

- (void) setStarFilling {
    UIImage *image = [self.post isStarred] ? filledStarImage : starImage;
    [self.starButton setImage:image
                     forState:UIControlStateNormal];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"HHPostCell: | frame: %@ | depth: %@ | text: %@...", NSStringFromCGRect(self.frame), @(self.indentationLevel), [self.bodyView.text substringToIndex:30]];
}

@end
