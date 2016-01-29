//
//  CommentViewController.m
//  u148
//
//  Created by 陈吉诗 on 14-7-23.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "CommentViewController.h"
#import "AFHTTPSessionManager.h"
#import "Comment.h"
#import "UIImageView+AFNetworking.h"
#import "User.h"
#import "CommentCell.h"
#import "QuartzCore/QuartzCore.h"
#import "UAccountManager.h"
#import "MBProgressHUD.h"
#import "UIImage+Color.h"

#define BASE_URL @"http://api.u148.net/json/get_comment/%@/%i"

#define TAG_HUD 101

@implementation CommentViewController {
    BOOL isKeyboardShow;
    
    UITableView *mTableView;
    UIView *mFootView;
    UITextField *mTextField;
    
    NSMutableArray *dataArray;
    NSDateFormatter *dateFormatter;
    
    NSRegularExpression *contentRegex;
    
    NSString *replyId;
    User *mUser;
    
    MBProgressHUD *progress;
    
    int page;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:246.0f/255 green:246.0f/255 blue:246.0f/255 alpha:1];
    self.title = @"";
    self.navigationController.navigationBar.topItem.title = @"评论";
    
    contentRegex = [NSRegularExpression regularExpressionWithPattern:@"(.+?)<blockquote>(.+?)<\\/blockquote>"
                                                                           options:NSRegularExpressionDotMatchesLineSeparators
                                                                             error:nil];
    
    mUser = [[UAccountManager sharedManager] getUserAccount];
    
    page = 1;
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44)
                                              style:UITableViewStylePlain];
    mTableView.dataSource = self;
    mTableView.delegate = self;
    mTableView.backgroundColor = [UIColor clearColor];
    [mTableView setSeparatorInset:UIEdgeInsetsZero];
    [mTableView setSeparatorColor:[UIColor colorWithRed:225.0f/255 green:225.0f/255 blue:225.0f/255 alpha:1]];
    
    mFootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    mFootView.backgroundColor = [UIColor clearColor];
    mFootView.hidden = YES;
    
    UIButton *footButton = [[UIButton alloc] initWithFrame:mFootView.frame];
    [footButton setTitle:@"加载更多" forState:UIControlStateNormal];
    [footButton setTitleColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0f/255.0 alpha:1.0]
                     forState:UIControlStateNormal];
    [footButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:0/255.0 alpha:1.0]
                     forState:UIControlStateHighlighted];
    footButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [footButton addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
    [mFootView addSubview:footButton];
    
    mTableView.tableFooterView = mFootView;
    
    [self.view addSubview:mTableView];
    
    UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44 - 4, self.view.bounds.size.width, 4)];
    CAGradientLayer *topShadow = [CAGradientLayer layer];
    topShadow.frame = CGRectMake(0, 0, self.view.bounds.size.width, 4);
    topShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1f] CGColor],
                        [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f],nil];
    topShadow.startPoint = CGPointMake(0, 4);
    topShadow.endPoint = CGPointMake(0, 0);
    [dividerView.layer insertSublayer:topShadow above:0];
    [self.view addSubview:dividerView];
    
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.bounds.size.width, 44)];
    commentView.backgroundColor = [UIColor whiteColor];
    commentView.userInteractionEnabled = YES;
    [self.view addSubview:commentView];
    
    mTextField = [[UITextField alloc] initWithFrame:CGRectMake(8, 0, self.view.bounds.size.width - 8 * 3 - 50, 44)];
    mTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    mTextField.backgroundColor = [UIColor clearColor];
    mTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    mTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    mTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    mTextField.returnKeyType = UIReturnKeyDone;
    mTextField.placeholder = @"写下你的评论";
    mTextField.delegate = self;
    [commentView addSubview:mTextField];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(mTextField.frame.origin.x + mTextField.frame.size.width + 8,
                                  7, 50, 34);
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    CALayer *layer = [sendButton layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:4.0f];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:255.0f/255 green:153.0f/255 blue:0 alpha:1.0f]]
                      forState:UIControlStateNormal];
    [sendButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:212.0f/255 green:128.0f/255 blue:0 alpha:1.0f]]
                      forState:UIControlStateHighlighted];
    [sendButton addTarget:self action:@selector(onCommentButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [commentView addSubview:sendButton];
    
    isKeyboardShow = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChange:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    
    [self request:YES];
}

- (void)onCommentButtonClicked
{
    NSString *content = mTextField.text;
    BOOL hasContent = content && content.length > 0;
    if (mUser && mUser.token && mUser.token.length > 0) {
        if (hasContent) [self sendComment:content];
    } else {
        if (hasContent) {
            [self performSelector:@selector(showLoginDialog) withObject:nil afterDelay:0.1];
        }
    }
    
    [self hideKeyboard];
}

- (void)showLoginDialog
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登陆" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登陆", nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    UITextField *userNameField = [alert textFieldAtIndex:0];
    userNameField.placeholder = @"邮箱";
    userNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    UITextField *passwordField = [alert textFieldAtIndex:1];
    passwordField.placeholder = @"密码";
    passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UITextField *userNameField = [alertView textFieldAtIndex:0];
        UITextField *passwordField = [alertView textFieldAtIndex:1];
        
        NSString *userName = userNameField.text;
        NSString *password = passwordField.text;
        
        if ([userName length] == 0 || [password length] == 0) {
            return;
        }
        
        [self login:userName withPassword:password];
    }
}

- (void)hideKeyboard
{
    [mTextField resignFirstResponder];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardWillHide:(NSNotification *)n
{
    [self changeViewFrame:0];
    isKeyboardShow = NO;
}

- (void)keyboardWillShow:(NSNotification *)n
{
    NSDictionary *userInfo = [n userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat offset = keyboardSize.height;
    
    [self changeViewFrame:offset];
    isKeyboardShow = YES;
}

- (void)keyboardDidChange:(NSNotification *)n
{
    if (isKeyboardShow) {
        NSDictionary *userInfo = [n userInfo];
        CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        CGFloat offset = keyboardSize.height;
        
        [self changeViewFrame:offset];
    }
}

- (void)changeViewFrame:(CGFloat)offset
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect viewFrame = screenRect;
    viewFrame.origin.y -= offset;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view setFrame:viewFrame];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [mTextField resignFirstResponder];
    return YES;
}

- (void)loadMore
{
    page++;
    [self request:NO];
}

- (void)login:(NSString *)name withPassword:(NSString *)password {
    NSDictionary *params = @{@"email" : [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                             @"password" : [password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:@"http://api.u148.net/json/login"
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              if ([responseObject isKindOfClass:[NSDictionary class]] == NO) return;
              
              NSDictionary *dict = (NSDictionary *) responseObject;
              NSInteger code = [[dict objectForKey:@"code"] integerValue];
              NSString *msg = @"登陆成功";
              if (code == 0) {
                  User *user = [[User alloc] initWithDictionary:[dict objectForKey:@"data"]];
                  [[UAccountManager sharedManager] setUserAccount:user];
              } else {
                  msg = [dict objectForKey:@"msg"];
              }
              [self showToast:msg];}
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              [self showToast:@"登陆失败，请检查用户名或密码，或者网络:)"];
          }];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [progress removeFromSuperview];
    progress = nil;
}

- (void)sendComment:(NSString *)content {
    progress = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progress];
    progress.delegate = self;
    [progress show:YES];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
    [params setObject:self.articleId forKey:@"id"];
    [params setObject:mUser.token forKey:@"token"];
    [params setObject:@"iPhone" forKey:@"client"];
    [params setObject:content forKey:@"content"];
    if (replyId) [params setObject:replyId forKey:@"review_id"];    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:@"http://api.u148.net/json/comment"
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              [progress hide:YES];
              [self showToast:@"评论成功"];
              replyId = nil;
              mTextField.placeholder = @"写下你的评论";
              mTextField.text = @"";
              [self request:YES];}
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              [progress hide:YES];
              [self showToast:@"评论失败，稍后再试"];
          }];
}

- (void)showToast:(NSString *)tips
{
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.tag = TAG_HUD;
    
    hud.mode = MBProgressHUDModeText;
    hud.labelText = tips;
    
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:2];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UIView *hudView = [self.view viewWithTag:TAG_HUD];
    if (hudView) {
        [hudView removeFromSuperview];
    }
}

- (void)request:(BOOL)refresh {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:[NSString stringWithFormat:BASE_URL, self.articleId, page]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if ([responseObject isKindOfClass:[NSDictionary class]] == NO) return;
             if (refresh) [dataArray removeAllObjects];
             
             NSDictionary *dict = (NSDictionary *) responseObject;
             NSDictionary *data = [dict objectForKey:@"data"];
             NSArray *array = [data objectForKey:@"data"];
             
             for (NSDictionary *item in array) {
                 Comment *comment = [[Comment alloc] initWithDictionary:item];
                 NSString *content = comment.contents;
                 NSArray *matches = [contentRegex matchesInString:content options:0 range:NSMakeRange(0, content.length)];
                 for (NSTextCheckingResult *match in matches) {
                     NSString *s1 = [content substringWithRange:[match rangeAtIndex:1]];
                     comment.contents = [s1 stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n\n"];
                     NSString *s2 = [content substringWithRange:[match rangeAtIndex:2]];
                     comment.reply = [s2 stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
                 }
                 
                 [dataArray addObject:comment];
             }
             
             [mTableView reloadData];
             if (array.count >= 30) {
                 mFootView.hidden = NO;
             } else {
                 mFootView.hidden = YES;
             }}
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = [dataArray objectAtIndex:indexPath.row];
    
    CGFloat h1 = [self getTextHeight:comment.contents];
    CGFloat h2 = [self getTextHeight:comment.reply];
    
    return h1 + h2 + 12 * 2 + 8 + 12;
}

- (CGFloat)getTextHeight:(NSString *)text
{
    CGSize contraint = CGSizeMake(self.view.frame.size.width - 8 * 2 - 40 - 8, 2000.0f);
    CGRect textRect = [text boundingRectWithSize:contraint
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
                                         context:nil];
    return textRect.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"commentCell";
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    Comment *comment = [dataArray objectAtIndex:indexPath.row];
    
    NSString *userName = comment.user.nickname;
    NSUInteger len = [userName length];
    NSString *stringFromDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[comment.createTime intValue]]];
    NSMutableAttributedString *userInfo = [[NSMutableAttributedString alloc] initWithString:
                                           [NSString stringWithFormat:@"%@ %@", userName, stringFromDate]];
    [userInfo addAttribute:NSForegroundColorAttributeName
                     value:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:0/255.0 alpha:1.0]
                     range:NSMakeRange(0, len)];
    
    NSString *imageUrl = comment.user.icon;
    [cell.imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"ic_place_holder.png"]];
    
    cell.textLabel.attributedText = userInfo;
    
    NSString *content = comment.contents;
    NSString *reply = comment.reply;
    if (reply) {
        NSString *result = [NSString stringWithFormat:@"%@ %@", content, reply];
        NSMutableAttributedString *attributString = [[NSMutableAttributedString alloc] initWithString:result];
        [attributString addAttribute:NSForegroundColorAttributeName
                               value:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]
                               range:NSMakeRange(content.length, reply.length + 1)];
        
        cell.detailTextLabel.attributedText = attributString;
    } else {
        content = [content stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
        cell.detailTextLabel.text = content;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = [dataArray objectAtIndex:indexPath.row];
    replyId = comment.commentId;
    mTextField.placeholder = [NSString stringWithFormat:@"回复:%@", comment.user.nickname];
}
@end
