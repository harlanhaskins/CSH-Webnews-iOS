//
//  ActivityThreadCell.m
//  CSH News
//
//  Created by Harlan Haskins on 1/26/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "ActivityThreadCell.h"
#import "ActivityThread.h"

@interface ActivityThreadCell ()

@end

@implementation ActivityThreadCell

+ (instancetype) cell {
    
    ActivityThreadCell *cell = [[ActivityThreadCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                         reuseIdentifier:[self reuseIdentifier]];
    
    cell.textLabel.backgroundColor =
    cell.detailTextLabel.backgroundColor =
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

+ (NSString*) reuseIdentifier {
    return @"ActivityThreadCell";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) prepareForReuse {
    self.textLabel.text = @"";
    self.detailTextLabel.text = @"";
    self.textLabel.textColor = [UIColor blackColor];
}

@end
