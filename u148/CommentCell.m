//
//  CommentCell.m
//  u148
//
//  Created by 陈吉诗 on 14-7-24.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:14];
        self.textLabel.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:14];
        self.detailTextLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = CGRectMake(8, 10, 40, 40);
    self.imageView.frame = rect;
    
    CGFloat x = rect.origin.x + rect.size.width + 8;
    CGFloat y = rect.origin.y;
    
    self.textLabel.frame = CGRectMake(x, y, self.frame.size.width - x - 8, 14);
    
    self.detailTextLabel.frame = CGRectMake(x, self.textLabel.frame.origin.y + self.textLabel.frame.size.height + 8,
                                            self.frame.size.width - x - 8, 0);
    self.detailTextLabel.numberOfLines = 0;
    [self.detailTextLabel sizeToFit];
}

- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
