//
//  CommentViewController.h
//  u148
//
//  Created by 陈吉诗 on 14-7-23.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@class User;

@interface CommentViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, UITableViewDataSource,
UITableViewDelegate, MBProgressHUDDelegate>

@property (nonatomic, assign) NSString *articleId;

@end
