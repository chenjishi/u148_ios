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
#import <MessageUI/MessageUI.h>
#import "SlideNavigationController.h"

@class CustomIOSAlertView;

@interface RootViewController : UIViewController <UIAlertViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate,
MFMailComposeViewControllerDelegate, TabBarDelegate, SlideNavigationControllerDelegate, OnMenuDelegate>
{
    NSInteger tabIndex;
    int clickCount;
    CustomIOSAlertView *aboutDialog;
    
    CGFloat tabWidth;
    NSInteger tabCount;
    TabIndicator *tabIndicator;
    
    UIScrollView *tabScrollView;
}

@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly) NSArray *controllers;
@property (nonatomic, strong) TabGroupView *tabGroupView;
@property (nonatomic, strong) MenuViewController *menuViewController;

- (id) initWithViewControllers:(NSArray *)controllers;

@end
