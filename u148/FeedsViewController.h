//
//  MainViewController.h
//  u148
//
//  Created by 陈吉诗 on 14-7-16.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableView *feedsTable;
@property (nonatomic, retain) NSMutableArray *feeds;

@property (nonatomic, retain) NSDictionary *categories;

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSUInteger categoryType;

@end
