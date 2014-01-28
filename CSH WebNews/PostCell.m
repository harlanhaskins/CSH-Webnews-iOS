//
//  PostCell.m
//  CSH News
//
//  Created by Harlan Haskins on 12/9/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import "ISO8601DateFormatter.h"
#import "PostCell.h"
#import "WebNewsDataHandler.h"
#import "Post.h"

@interface PostCell ()

@property (nonatomic, readwrite) Post *post;

@end

@implementation PostCell {
}

+ (instancetype) cellWithPost:(Post*)post level:(NSInteger)level
{
    PostCell *cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self cellIdentifier]];
    cell.post = post;
    
    cell.textLabel.textColor = [post subjectColor];
    
    NSString *parameters = [NSString stringWithFormat:@"%@%@/%i",kBaseURLFormat, post.newsgroup, post.number];
    
    [WebNewsDataHandler runHTTPOperationWithParameters:parameters success:^(AFHTTPRequestOperation *op, id response) {
        cell.post = response;
    } failure:nil];
    
    cell.textLabel.text = cell.post.subject;
    cell.detailTextLabel.text = [cell.post authorshipAndTimeString];
    return cell;
}

+ (NSString*) cellIdentifier {
    return @"PostCell";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
