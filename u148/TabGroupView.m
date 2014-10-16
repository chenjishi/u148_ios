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
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation TabGroupView

@synthesize tabDelegate = _tabDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:240.0f/255 green:240.0f/255 blue:240.0f/255 alpha:1.0];
        
        NSArray *titleArray = @[@"首页", @"图画", @"文字", @"音频", @"短品", @"杂粹", @"影像", @"集市", @"漂流"];
        tabCount = [titleArray count];
        tabWidth = frame.size.width * 1.0f / 6;
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            self.panGestureRecognizer.delaysTouchesBegan = YES;
        }

        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.autoresizesSubviews = NO;
        self.autoresizingMask = UIViewAutoresizingNone;
        
        for (NSInteger i = 0; i < tabCount; i++) {
            CGRect rect = CGRectMake(tabWidth * i, 0, tabWidth, frame.size.height);
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = rect;
            button.tag = TAB_VIEW_TAG + i;
            [button setTitle:[titleArray objectAtIndex:i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            button.backgroundColor = [UIColor clearColor];
            [button addTarget:self action:@selector(tabClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:button];
        }       
        
        tabIndicator = [[TabIndicator alloc] initWithFrame:CGRectMake(0, 0, tabWidth, frame.size.height)];
        [self addSubview:tabIndicator];
    }
    
    self.contentSize = CGSizeMake(tabCount * tabWidth, frame.size.height);   
    return self;
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    return YES;
}

- (void)tabClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSUInteger index = button.tag - TAB_VIEW_TAG;
    
    if (_tabDelegate) {
        [_tabDelegate onTabClicked:index];
    }
}

- (void)setIndexAt:(NSUInteger)index
{
    CGRect frame = tabIndicator.frame;
    frame.origin.x = index * tabWidth;
    tabIndicator.frame = frame;
    
    for (NSUInteger i = 0; i < tabCount; i++) {
        UIButton *label = (UIButton*) [self viewWithTag:TAB_VIEW_TAG + i];
        if (i == index) {
            [label setTitleColor:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:0/255.0 alpha:1.0] forState:UIControlStateNormal];
        } else {
            [label setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        }
    }
    
    CGFloat x;
    if (index >= 5) {
        x = (index + 1) * tabWidth;
    } else {
        x = (index - 1) * tabWidth;
    }
    CGRect rect = CGRectMake(x, 0, tabWidth, self.frame.size.height);
    [self scrollRectToVisible:rect animated:YES];
}
@end
