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

@property (nonatomic, readwrite) ActivityThread *thread;

@end

@implementation ActivityThreadCell

+ (instancetype) cellWithActivityThread:(ActivityThread*)thread reuseIdentifier:(NSString *)reuseID {
    
    ActivityThreadCell *cell = [[ActivityThreadCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                         reuseIdentifier:reuseID];
    
    cell.thread = thread;
    
    cell.textLabel.text = cell.thread.parentPost.subject;
    cell.detailTextLabel.text = [cell.thread.parentPost authorshipAndTimeString];
    
    cell.textLabel.textColor = [cell.thread.parentPost subjectColor];
    cell.textLabel.backgroundColor =
    cell.detailTextLabel.backgroundColor =
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
