//
//  FavoriteViewController.h
//  u148
//
//  Created by 陈吉诗 on 14-8-2.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    int page;
    NSString *userToken;
    UITableView *favoriteTable;
    NSMutableArray *dataArray;
    NSDateFormatter *dateFormat;
}

@end
