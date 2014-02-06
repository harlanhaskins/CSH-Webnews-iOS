//
//  HHCommentThreadView.m
//  CSH News
//
//  Created by Harlan Haskins on 2/5/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "HHThreadScrollView.h"
#import "HHCollapsiblePostCell.h"
#import "HHPostProtocol.h"

@interface HHThreadScrollView ()

@property (nonatomic) HHCollapsiblePostCell *parentCell;
@property (nonatomic, readwrite) NSArray *allCells;
@property (nonatomic) BOOL laidOutSubviews;

@end

@implementation HHThreadScrollView

+ (instancetype) threadViewWithParentCell:(HHCollapsiblePostCell*)cell {
    HHThreadScrollView *threadView = [HHThreadScrollView new];
    threadView.parentCell = cell;
//    threadView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
    return threadView;
}

+ (instancetype) threadViewWithParentPost:(id<HHPostProtocol>)post {
    HHCollapsiblePostCell *cell = [HHCollapsiblePostCell cellWithPost:post];
    return [self threadViewWithParentCell:cell];
}

- (void) setParentCell:(HHCollapsiblePostCell *)parentCell {
    _parentCell = parentCell;
    [self addAllCellsAsSubviews];
}

- (void) addAllCellsAsSubviews {
    for (int i = 0; i < self.allCells.count; i++) {
        HHCollapsiblePostCell *cell = self.allCells[i];
        [self addSubview:cell];
    }
}

- (void) layoutSubviews {
    if (!self.laidOutSubviews) {
        CGPoint origin = CGPointZero;
        for (int i = 0; i < self.allCells.count; i++) {
            HHCollapsiblePostCell *cell = self.allCells[i];
            
            CGRect cellRect = cell.frame;
            cellRect.origin = origin;
            cellRect.size = [cell sizeThatFits:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)];
            cell.frame = cellRect;
            origin.y += cellRect.size.height;
        }
        self.laidOutSubviews = YES;
        [self reloadContentSize];
    }
}

- (void) setFrame:(CGRect)frame {
    self.laidOutSubviews = NO;
    [super setFrame:frame];
}

- (void) reloadContentSize {
    UIView *lastCollapsibleCell = [self.allCells lastObject];
    self.contentSize = CGSizeMake(self.frame.size.width, lastCollapsibleCell.frame.origin.y + lastCollapsibleCell.frame.size.height);
}

- (NSArray*) allCells {
    if (!_allCells) {
        _allCells = [self recursivelyAddAllCellsFromCell:self.parentCell];
    }
    return _allCells;
}

- (NSArray *) recursivelyAddAllCellsFromCell:(HHCollapsiblePostCell*)cell {
    NSMutableArray *array = [NSMutableArray array];
    for (HHCollapsiblePostCell *childCell in cell.children) {
        [array addObject:cell];
        [array addObjectsFromArray:[self recursivelyAddAllCellsFromCell:childCell]];
    }
    return array;
}

@end
