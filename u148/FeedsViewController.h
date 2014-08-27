//
//  MainViewController.h
//  u148
//
//  Created by 陈吉诗 on 14-7-16.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *dataArray;
    NSMutableParagraphStyle *paragraphStyle;
    NSDictionary *categories;
    UITableView *mTableView;
    UIView *mFootView;
    int page;
}

@property (nonatomic, assign) NSUInteger categoryType;

@end
