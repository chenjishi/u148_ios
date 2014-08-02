//
//  RootViewController.h
//  u148
//
//  Created by 陈吉诗 on 14-7-20.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "TabGroupView.h"

@interface RootViewController : UIViewController <UIScrollViewDelegate, SlideMenuDelegate,
UIAlertViewDelegate, TabBarDelegate>
{
    NSInteger tabIndex;
}

@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly) NSArray *controllers;
@property (nonatomic, strong) TabGroupView *tabGroupView;
@property (nonatomic, strong) MenuViewController *menuViewController;
@property (nonatomic, assign) BOOL isMenuShow;

- (id) initWithViewControllers:(NSArray *)controllers;

@end
