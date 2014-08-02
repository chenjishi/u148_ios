//
//  CommentViewController.h
//  u148
//
//  Created by 陈吉诗 on 14-7-23.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;

@interface CommentViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
    BOOL isKeyboardShow;
}

@property (nonatomic, strong) UITableView *commentTableView;
@property (nonatomic, strong) UITextField *commentField;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) NSString *replyId;
@property (nonatomic, assign) NSString *articleId;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) User *user;

@end
