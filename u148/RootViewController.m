//
//  RootViewController.m
//  u148
//
//  Created by 陈吉诗 on 14-7-20.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "RootViewController.h"
#import "MenuViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

@synthesize scrollView = _scrollView, controllers = _controllers, contentView = _contentView;

- (id) initWithViewControllers:(NSArray *)controllers
{
    if (self = [super init]) {
        _controllers = controllers;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"有意思吧";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"ic_menu.png"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    menuButton.frame = CGRectMake(0, 0, 32.5f, 30);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:0/255.0 alpha:1.0]];
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    [self.view addSubview:_contentView];
    
    tabIndex = 0;
    self.tabGroupView = [[TabGroupView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 36)];
    [self.tabGroupView setIndexAt:tabIndex];
    self.tabGroupView.delegate = self;
    [_contentView addSubview:self.tabGroupView];
    
    CGRect rect = CGRectMake(0, 36, self.view.frame.size.width, _contentView.frame.size.height - 36);
    _scrollView = [[UIScrollView alloc] initWithFrame:rect];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.contentSize = CGSizeMake(_controllers.count * rect.size.width, rect.size.height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.autoresizesSubviews = NO;
    _scrollView.autoresizingMask = UIViewAutoresizingNone;
    [_contentView addSubview:self.scrollView];
    
    for (UIViewController *viewControllers in self.controllers) {
        [self.scrollView addSubview:viewControllers.view];
        [self addChildViewController:viewControllers];
    }
    
    self.menuViewController = [[MenuViewController alloc] init];
    self.menuViewController.delegate = self;
    self.menuViewController.view.frame = CGRectMake(-200, 64, 200, self.view.frame.size.height - 64);
    self.isMenuShow = NO;
}

- (void)onTabClicked:(NSUInteger)index
{
    if (tabIndex != index) {
        tabIndex = index;
        
        [self.tabGroupView setIndexAt:tabIndex];
        
        CGRect frame = _scrollView.frame;
        frame.origin.x = frame.size.width * tabIndex;
        [_scrollView scrollRectToVisible:frame animated:YES];
    }
}

- (void)onMenuClicked:(NSUInteger)index
{
    NSLog(@"clicked at %d", index);
    [self hideMenu];
}

- (void)hideMenu
{
    [UIView animateWithDuration:0.3 animations:^{
        _contentView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
        self.menuViewController.view.frame = CGRectMake(-200, 64, 200, self.view.frame.size.height - 64);
    } completion:^(BOOL finished) {
        [self.menuViewController.view removeFromSuperview];
        self.isMenuShow = NO;
    }];
}

- (void)showMenu
{
    [self.view insertSubview:self.menuViewController.view aboveSubview:_contentView];
    [UIView animateWithDuration:0.3 animations:^{
        if (self.isMenuShow) {
            _contentView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
            self.menuViewController.view.frame = CGRectMake(-200, 64, 200, self.view.frame.size.height - 64);
        } else{
            CGRect rect = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
            _contentView.frame = CGRectOffset(rect, 200, 0);
            self.menuViewController.view.frame = CGRectMake(0, 64, 200, self.view.frame.size.height - 64);
        }
    } completion:^(BOOL finished) {
        if (self.isMenuShow) {
            [self.menuViewController.view removeFromSuperview];
        }
        self.isMenuShow = !self.isMenuShow;
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    for (UIViewController *viewController in self.controllers) {
        NSUInteger index = [self.controllers indexOfObject:viewController];
        CGRect frame = viewController.view.frame;
        frame.origin.x = self.view.frame.size.width * index;
        viewController.view.frame = frame;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSUInteger index = floor(scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5);
    if (index != tabIndex) {
        tabIndex = index;
        [self.tabGroupView setIndexAt:index];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; 
}
@end
