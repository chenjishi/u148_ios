//
//  TabGroupView.h
//  u148
//
//  Created by 陈吉诗 on 14-7-20.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TabIndicator;

@protocol TabBarDelegate <NSObject>

@required
- (void)onTabClicked:(NSUInteger)index;

@end

@interface TabGroupView : UIView
{
    CGFloat tabWidth;
}

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) TabIndicator *tabIndicator;
@property (nonatomic, assign) id<TabBarDelegate> delegate;

- (void)setIndexAt:(NSUInteger)index;

@end
