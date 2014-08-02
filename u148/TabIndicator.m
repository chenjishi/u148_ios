//
//  TabIndicator.m
//  u148
//
//  Created by 陈吉诗 on 14-8-1.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "TabIndicator.h"

@implementation TabIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect stripRect = CGRectMake(0, self.frame.size.height - 4, self.frame.size.width, 4);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *color = [UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:0/255.0 alpha:1.0];
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, stripRect);    
}

@end
