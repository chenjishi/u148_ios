//
//  TabGroupView.m
//  u148
//
//  Created by 陈吉诗 on 14-7-20.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "TabGroupView.h"
#import "TabIndicator.h"

#define TAB_VIEW_TAG  200

@implementation TabGroupView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titles = [NSArray arrayWithObjects:@"首页", @"图画", @"文字", @"杂粹", @"音频", @"漂流", nil];
        
        self.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1.0];
        
        NSUInteger count = self.titles.count;
        tabWidth = frame.size.width * 1.0f / count;
        
        self.tabIndicator = [[TabIndicator alloc] initWithFrame:CGRectMake(0, 0, tabWidth, frame.size.height)];
        
        for (NSUInteger i = 0; i < count; i++) {
            CGRect rect = CGRectMake(tabWidth * i, 0, tabWidth, frame.size.height);
            UIButton *label = [UIButton buttonWithType:UIButtonTypeCustom];
            label.frame = rect;
            label.tag = TAB_VIEW_TAG + i;
            [label setTitle:[self.titles objectAtIndex:i] forState:UIControlStateNormal];
            [label setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            label.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            label.backgroundColor = [UIColor clearColor];
            [label addTarget:self action:@selector(tabClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:label];
        }
        
        [self addSubview:self.tabIndicator];
    }
    return self;
}

- (void)tabClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSUInteger index = button.tag - TAB_VIEW_TAG;
    
    if (_delegate) {
        [_delegate onTabClicked:index];
    }
}

- (void)setIndexAt:(NSUInteger)index
{
    CGRect frame = self.tabIndicator.frame;
    frame.origin.x = index * tabWidth;
    self.tabIndicator.frame = frame;
    
    for (NSUInteger i = 0; i < self.titles.count; i++) {
        UIButton *label = (UIButton*) [self viewWithTag:TAB_VIEW_TAG + i];
        if (i == index) {
            [label setTitleColor:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:0/255.0 alpha:1.0] forState:UIControlStateNormal];
        } else {
            [label setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        }
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
