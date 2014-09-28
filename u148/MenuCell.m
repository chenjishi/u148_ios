//
//  MenuCell.m
//  u148
//
//  Created by 陈吉诗 on 14-8-2.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "MenuCell.h"

@implementation MenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:16.0f];
        self.textLabel.textColor = [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0];
        
        UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 200, 1)];
        CGFloat color = 85.0f / 255;
        divider.backgroundColor = [UIColor colorWithRed:color green:color blue:color alpha:1.0f];
        [self.contentView addSubview:divider];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:39.0f/255 green:42.0f/255 blue:44.0f/255 alpha:1.0f];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(10, 12, 20, 20);
    self.textLabel.frame = CGRectMake(38, 14, 0, 0);
    [self.textLabel sizeToFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
