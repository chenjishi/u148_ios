//
//  MenuViewController.h
//  u148
//
//  Created by 陈吉诗 on 14-7-21.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;

@protocol SlideMenuDelegate <NSObject>

@required

- (void)onMenuClicked:(NSUInteger)index;

@end

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    User *user;
    NSMutableArray *titles;
    NSMutableArray *icons;
    UITableView *menuTableView;
}

@property (assign, nonatomic) id<SlideMenuDelegate> delegate;

- (void)refreshMenu;

@end
