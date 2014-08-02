//
//  FeedCell.m
//  u148
//
//  Created by 陈吉诗 on 14-7-19.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "FeedCell.h"

@implementation FeedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        self.textLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        self.detailTextLabel.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0f/255.0 alpha:1.0];
        
        self.reviewsLabel = [[UILabel alloc] init];
        self.reviewsLabel.font = [UIFont systemFontOfSize:12.0];
        self.reviewsLabel.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0f/255.0 alpha:1.0];
        self.reviewsLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.reviewsLabel];
        
        self.backgroundView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = CGRectMake(8, 8, 80, 87);
    self.imageView.frame = rect;
    
    int x = rect.origin.x + rect.size.width + 8;
    self.textLabel.frame = CGRectMake(x, rect.origin.y,
                                      self.frame.size.width - x - 8, 15);
    
    self.detailTextLabel.frame = CGRectMake(x, self.textLabel.frame.origin.y
                                            + self.textLabel.frame.size.height + 8,
                                            self.frame.size.width - x - 8, 0);
    self.detailTextLabel.adjustsFontSizeToFitWidth = NO;
    self.detailTextLabel.numberOfLines = 2;
    [self.detailTextLabel sizeToFit];
    
    self.reviewsLabel.frame = CGRectMake(x, self.frame.size.height - 8 - 12, self.frame.size.width - x - 8, 12);
}

- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
