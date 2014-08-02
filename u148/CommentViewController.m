//
//  CommentViewController.m
//  u148
//
//  Created by 陈吉诗 on 14-7-23.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "CommentViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "Comment.h"
#import "UIImageView+AFNetworking.h"
#import "User.h"
#import "CommentCell.h"
#import "QuartzCore/QuartzCore.h"
#import "UAccountManager.h"
#import "MBProgressHUD.h"
#import "FUIButton.h"

#define BASE_URL @"http://www.u148.net/json/get_comment/%@/%i"
#define COMMENT_URL @"http://www.u148.net/json/comment"
#define LOGIN_URL @"http://www.u148.net/json/login"

@interface CommentViewController ()

@end

@implementation CommentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1];
    self.navigationController.navigationBar.topItem.title = @"评论";
    
    self.user = [[UAccountManager sharedManager] getUserAccount];
    
    self.page = 1;
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    self.comments = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.commentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44)
                                                         style:UITableViewStylePlain];
    self.commentTableView.dataSource = self;
    self.commentTableView.delegate = self;
    self.commentTableView.backgroundColor = [UIColor clearColor];
    [self.commentTableView setSeparatorInset:UIEdgeInsetsZero];
    [self.commentTableView setSeparatorColor:[UIColor colorWithRed:232.0/255.0 green:232.0/255.0 blue:232.0/255.0 alpha:1.0]];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    footView.backgroundColor = [UIColor clearColor];
    
    UIButton *footButton = [[UIButton alloc] initWithFrame:footView.frame];
    [footButton setTitle:@"加载更多" forState:UIControlStateNormal];
    [footButton setTitleColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0f/255.0 alpha:1.0]
                     forState:UIControlStateNormal];
    footButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [footButton addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:footButton];
    
    self.commentTableView.tableFooterView = footView;
    
    [self.view addSubview:self.commentTableView];
    
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.bounds.size.width, 44)];
    commentView.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1];
    commentView.userInteractionEnabled = YES;
    CAGradientLayer *topShadow = [CAGradientLayer layer];
    topShadow.frame = CGRectMake(0, 0, self.view.bounds.size.width, 4);
    topShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1f] CGColor],
                        [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f],nil];
    topShadow.startPoint = CGPointMake(0, 4);
    topShadow.endPoint = CGPointMake(0, 0);
    [commentView.layer insertSublayer:topShadow above:0];
    [self.view addSubview:commentView];
    
    self.commentField = [[UITextField alloc] initWithFrame:CGRectMake(8, 0, self.view.bounds.size.width - 8 * 3 - 50, 44)];
    self.commentField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.commentField.backgroundColor = [UIColor clearColor];
    self.commentField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.commentField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.commentField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.commentField.placeholder = @"写下你的评论";
    self.commentField.delegate = self;
    [commentView addSubview:self.commentField];
    
    FUIButton *sendButton = [FUIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(self.commentField.frame.origin.x + self.commentField.frame.size.width + 8,
                                  7, 50, 34);
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    sendButton.buttonColor = [UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:0/255.0 alpha:1.0];
    sendButton.shadowColor = [UIColor colorWithRed:230.0/255.0 green:138.0/255.0 blue:1/255.0 alpha:1.0];
    sendButton.shadowHeight = 2.0f;
    sendButton.cornerRadius = 4.0f;
    [sendButton addTarget:self action:@selector(onCommentButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [commentView addSubview:sendButton];
    
    isKeyboardShow = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    [self request];
}

- (void)onCommentButtonClicked
{
    if (!self.user) {
        [self performSelector:@selector(showLoginDialog) withObject:nil afterDelay:0.1];
    } else{
        NSString *content = self.commentField.text;
        if ([content length] == 0) {
            return;
        } else {
            [self sendComment:content];
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
    [self.commentField resignFirstResponder];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillHide:(NSNotification *)n
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGRect viewFrame = CGRectMake(0, 0, screenWidth, screenHeight);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    
    isKeyboardShow = NO;
}

- (void)keyboardWillShow:(NSNotification *)n
{
    if (isKeyboardShow) return;
    
    NSDictionary *userInfo = [n userInfo];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect viewFrame = screenRect;
    viewFrame.origin.y -= keyboardSize.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    
    isKeyboardShow = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.commentField resignFirstResponder];
    return YES;
}

- (void)loadMore
{
    self.page++;
    [self request];
}

- (void)login:(NSString *)name withPassword:(NSString *)password
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSDictionary *params = @{@"email" : name, @"password" : password};
    [manager POST:[NSString stringWithFormat:LOGIN_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *) responseObject;
            NSDictionary *data = [dict objectForKey:@"data"];
            
            User *user = [User alloc];
            user.icon = [data objectForKey:@"icon"];
            user.nickname = [data objectForKey:@"nickname"];
            user.sexStr = [data objectForKey:@"sex"];
            user.token = [data objectForKey:@"token"];
            
            self.user = user;
            [[UAccountManager sharedManager] setUserAccount:self.user];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail %@", error);
        
    }];
}

- (void)sendComment:(NSString *)content
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
    [params setObject:self.articleId forKey:@"id"];
    [params setObject:self.user.token forKey:@"token"];
    [params setObject:[NSString stringWithFormat:@"%@(iPhone客户端)", content] forKey:@"content"];
    if (self.replyId != nil) {
        [params setObject:self.replyId forKey:@"review_id"];
    }
    
    [manager POST:[NSString stringWithFormat:COMMENT_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self showToast:@"评论成功"];
        self.replyId = nil;
        self.commentField.placeholder = @"写下你的评论";
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showToast:@"评论失败，稍后再试"];
    }];
}

- (void)showToast:(NSString *)tips
{
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.mode = MBProgressHUDModeText;
    hud.labelText = tips;
    
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:3];
}

- (void)request
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    [manager GET:[NSString stringWithFormat:BASE_URL, self.articleId, self.page]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             if ([responseObject isKindOfClass:[NSDictionary class]]) {
                 NSDictionary *dict = (NSDictionary *) responseObject;
                 NSDictionary *data = [dict objectForKey:@"data"];
                 NSArray *array = [data objectForKey:@"data"];
                 
                 for (NSDictionary *item in array) {
                     Comment *comment = [[Comment alloc] initWithDictionary:item];
                     [self.comments addObject:comment];
                 }
                 
                 [self.commentTableView reloadData];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"error %@", error);
         }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.comments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [[self.comments objectAtIndex:indexPath.row] contents];
    CGSize contraint = CGSizeMake(self.view.frame.size.width - 8 * 2 - 40 - 8, 2000.0f);
    
    CGRect textRect = [text boundingRectWithSize:contraint
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
                                         context:nil];
    CGFloat textHeight = textRect.size.height;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<br.*?/>"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSUInteger matches = [regex numberOfMatchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    //we replace <br/> to line break, so we should add the height
    textHeight += matches * 14;
    
    return textHeight + 10 * 2 + 8 + 14;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"commentCell";
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    Comment *comment = [self.comments objectAtIndex:indexPath.row];
    
    NSString *userName = comment.user.nickname;
    NSUInteger len = [userName length];
    NSString *stringFromDate = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[comment.createTime intValue]]];
    NSMutableAttributedString *userInfo = [[NSMutableAttributedString alloc] initWithString:
                                           [NSString stringWithFormat:@"%@ %@", userName, stringFromDate]];
    [userInfo addAttribute:NSForegroundColorAttributeName
                     value:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:0/255.0 alpha:1.0]
                     range:NSMakeRange(0, len)];
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:comment.user.icon]
                   placeholderImage:[UIImage imageNamed:@"user_default.png"]];
    cell.textLabel.attributedText = userInfo;
    cell.detailTextLabel.text = comment.contents;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<blockquote>(.+?)</blockquote>"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSString *content = comment.contents;
    NSString *replyContent = nil;
    NSArray *matches = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        replyContent = [content substringWithRange:matchRange];
    }
    
    if (replyContent != nil) {
        content = [content stringByReplacingOccurrencesOfString:replyContent withString:@""];
        content = [content stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
        replyContent = [replyContent stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
        replyContent = [replyContent stringByReplacingOccurrencesOfString:@"<blockquote>" withString:@""];
        replyContent = [replyContent stringByReplacingOccurrencesOfString:@"</blockquote>" withString:@""];
        
        
        NSMutableAttributedString *attributString = [[NSMutableAttributedString alloc] initWithString:
                                                     [NSString stringWithFormat:@"%@\n%@", content, replyContent]];
        [attributString addAttribute:NSForegroundColorAttributeName
                               value:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]
                               range:NSMakeRange(content.length, replyContent.length + 1)];
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = [self.comments objectAtIndex:indexPath.row];
    self.replyId = comment.userId;
    self.commentField.placeholder = [NSString stringWithFormat:@"回复:%@", comment.user.nickname];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
