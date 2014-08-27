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
    
    UITableView *mTableView;
    UIView *mFootView;
    UITextField *mTextField;
    
    NSMutableArray *dataArray;
    NSDateFormatter *dateFormatter;
    
    NSString *replyId;
    User *mUser;
    
    int page;
}

@property (nonatomic, assign) NSString *articleId;

@end
