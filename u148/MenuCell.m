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
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f];
        
        UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 1)];
        divider.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.1];
        [self.contentView addSubview:divider];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:39.0f/255 green:42.0f/255 blue:44.0f/255 alpha:0.2];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(10, 17, 20, 20);
    self.textLabel.frame = CGRectMake(38, 19, 0, 0);
    [self.textLabel sizeToFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
