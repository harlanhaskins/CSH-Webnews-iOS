//
//  PostCell.m
//  CSH News
//
//  Created by Harlan Haskins on 2/4/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "PostCell.h"
#import "UIColor+CSH.h"
#import "NewsgroupThread.h"
#import "TTTAttributedLabel.h"

@interface PostCell ()

@property (nonatomic) BOOL actionButtonsVisible;

@property (weak, nonatomic) IBOutlet UILabel *dotLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *bodyView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *starButton;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;

@property (nonatomic) NSString *headerText;

@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *headerIndentationConstraint;

@property (nonatomic) CGFloat textViewHeight;
@property (weak, nonatomic) IBOutlet UIStackView *buttonView;

@end

static UIImage *starImage;
static UIImage *filledStarImage;
static NSMutableDictionary *memoizedColors;

static CGFloat const IndentationColorStartingValue = 0.95;

@implementation PostCell

+ (void) initialize {
    starImage = [UIImage imageNamed:@"Star"];
    filledStarImage = [UIImage imageNamed:@"StarFilled"];
    memoizedColors = [NSMutableDictionary dictionary];
}

-(void)awakeFromNib {
    [super awakeFromNib];
    self.bodyView.enabledTextCheckingTypes = NSTextCheckingTypeDate | NSTextCheckingTypeAddress | NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber;
    self.bodyView.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    self.bodyView.activeLinkAttributes =
    self.bodyView.inactiveLinkAttributes = @{
        NSForegroundColorAttributeName : [UIColor infoColor],
        NSUnderlineStyleAttributeName : @(NSUnderlineStyleNone)
    };
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
    self.dotLabel.hidden = (self.dotLabel.text.length == 0);
    self.timeLabel.text = self.post.friendlyDate;
    UIColor *labelColor = [UIColor darkGrayColor];
    if (self.post.unread) {
        labelColor = [UIColor infoColor];
    }
    self.headerLabel.textColor = self.dotLabel.textColor = self.timeLabel.textColor = labelColor;
}

- (void) initializePostBody {
    self.bodyView.text = self.post.attributedBody;
    self.bodyView.preferredMaxLayoutWidth = self.bodyView.frame.size.width;
    
    self.subjectLabel.text = self.post.subject;
}

-(void)touchesBegan:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:0 animations:^{
        self.buttonView.hidden = !self.buttonView.hidden;
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
    } completion:nil];
}

- (void) prepareForReuse {
    _post = nil; // Don't use the setter.
}

- (void)setDelegate:(id<PostCellDelegate>)delegate {
    _delegate = delegate;
    self.bodyView.delegate = delegate;
}

- (void) setAttributedText:(NSAttributedString*)text {
    self.bodyView.attributedText = text;
}

- (void) setText:(NSString*) text {
    self.bodyView.text = text;
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
    self.indentationLevel = post.depth;
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
    return [NSString stringWithFormat:@"PostCell: | frame: %@ | depth: %@ | text: %@...", NSStringFromCGRect(self.frame), @(self.indentationLevel), [self.bodyView.text substringToIndex:MIN(30, [self.bodyView.text length])]];
}

@end
