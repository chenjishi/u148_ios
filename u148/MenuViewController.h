//
//  MenuViewController.h
//  u148
//
//  Created by 陈吉诗 on 14-7-21.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;

@protocol OnMenuDelegate <NSObject>

- (void)onMenuClickedAt:(NSInteger)index;

@end

@interface MenuViewController : UITableViewController

@property (nonatomic, strong) id<OnMenuDelegate> delegate;

- (void)refreshMenu;

@end
