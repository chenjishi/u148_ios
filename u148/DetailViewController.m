//
//  DetailViewController.m
//  u148
//
//  Created by 陈吉诗 on 14-7-22.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "DetailViewController.h"
#import "Feed.h"
#import "User.h"
#import "UAccountManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "PhotoViewController.h"
#import "CommentViewController.h"
#import "MBProgressHUD.h"

#define BASE_URL @"http://www.u148.net/json/article/%@"
#define URL_FAVORITE_ADD @"http://www.u148.net/json/favourite"
#define LOGIN_URL @"http://www.u148.net/json/login"

@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize feed = _feed;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1];
    
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentButton setImage:[UIImage imageNamed:@"ic_comment.png"] forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(startComment) forControlEvents:UIControlEventTouchUpInside];
    commentButton.frame = CGRectMake(0, 0, 34, 34);
    UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
    
    UIButton *favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [favoriteButton setImage:[UIImage imageNamed:@"ic_favorite.png"] forState:UIControlStateNormal];
    favoriteButton.frame = CGRectMake(0, 0, 34, 34);
    [favoriteButton addTarget:self action:@selector(onFavoriteButtonCliked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *favoriteItem = [[UIBarButtonItem alloc] initWithCustomView:favoriteButton];
    
    self.navigationItem.rightBarButtonItems = @[commentItem, favoriteItem];
    
    NSDictionary *titles = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"首页", [NSNumber numberWithInt:0],
                            @"图画", [NSNumber numberWithInt:3],
                            @"文字", [NSNumber numberWithInt:6],
                            @"杂粹", [NSNumber numberWithInt:7],
                            @"集市", [NSNumber numberWithInt:9],
                            @"漂流", [NSNumber numberWithInt:8],
                            @"游戏", [NSNumber numberWithInt:4],
                            @"影像", [NSNumber numberWithInt:2],
                            @"音频", [NSNumber numberWithInt:5],  nil];
    
    self.navigationController.navigationBar.topItem.title = [titles objectForKey:[NSNumber numberWithInt:self.feed.category]];
    
    self.webview = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.webview.delegate = self;
    [self.view addSubview:self.webview];

    
    [self renderPage:@"正在加载..."];
    
    [self request];
}

- (void)request
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    [manager GET:[NSString stringWithFormat:BASE_URL, _feed.feedId]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             if ([responseObject isKindOfClass:[NSDictionary class]]) {
                 NSDictionary *dict = (NSDictionary *) responseObject;
                 NSDictionary *data = [dict objectForKey:@"data"];
                 
                 NSString *content = [data objectForKey:@"content"];
                 [self renderPage:content];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"error %@", error);
         }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UITextField *userNameField = [alertView textFieldAtIndex:0];
        UITextField *passwordField = [alertView textFieldAtIndex:1];
        
        NSString *userName = userNameField.text;
        NSString *password = passwordField.text;
        
        if ([userName length] == 0 || [password length] == 0) {
            [self showToast:@"请输入用户名或密码"];
            return;
        }
        
        [self login:userName withPassword:password];
    }
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
            
            [[UAccountManager sharedManager] setUserAccount:user];
            [self showToast:@"登陆成功"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showToast:@"登陆失败，请检查用户名或密码，或者网络:)"];
    }];
}

- (void)showToast:(NSString *)tips
{
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.mode = MBProgressHUDModeText;
    hud.labelText = tips;
    
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:2];
}

- (void)showLoginDialog
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登陆"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"登陆", nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    UITextField *userNameField = [alert textFieldAtIndex:0];
    userNameField.placeholder = @"邮箱";
    userNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    UITextField *passwordField = [alert textFieldAtIndex:1];
    passwordField.placeholder = @"密码";
    passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [alert show];
}

- (void)onFavoriteButtonCliked
{
    User *user = [[UAccountManager sharedManager] getUserAccount];
    if (user != nil && user.token.length > 0) {
        [self addToFavorites:user.token];
    } else {
        [self showLoginDialog];
    }
}

- (void)addToFavorites:(NSString *)userToken
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSDictionary *params = @{@"id" : _feed.feedId, @"token" : userToken};
    
    [manager POST:[NSString stringWithFormat:URL_FAVORITE_ADD]
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              [self showToast:@"已移入收藏夹"];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self showToast:@"服务器繁忙，请稍后再试"];
          }];
}

- (void)startComment
{
    CommentViewController *commentViewController = [[CommentViewController alloc] init];
    commentViewController.articleId = _feed.feedId;
    [self.navigationController pushViewController:commentViewController animated:YES];
}

- (void)renderPage:(NSString *)content
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"usite" ofType:@"html" inDirectory:@"html"]];
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"usite" ofType:@"html" inDirectory:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{TITLE}" withString:self.feed.title];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *stringFromDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.feed.createTime]];
    
    NSString *author = nil;
    NSString *reviews = nil;
    if (_feed.user) {
        author = [NSString stringWithFormat:@"%@  %@", _feed.user.nickname, stringFromDate];
        reviews = [NSString stringWithFormat:@"%i人看过  %i评论", _feed.browses, _feed.reviews];
    } else {
        author = [NSString stringWithFormat:@"有意思吧  %@", stringFromDate];
        reviews = @"";
    }
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{U_AUTHOR}" withString:author];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{U_COMMENT}" withString:reviews];    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{CONTENT}" withString:content];
    
    [self.webview loadHTMLString:htmlString baseURL:url];    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request URL] absoluteString] hasPrefix:@"ios:"]) {
        
        NSArray *array = [[[request URL] absoluteString] componentsSeparatedByString:@"&"];
        
        NSLog(@"%@", [array objectAtIndex:0]);
        NSLog(@"%@", [array objectAtIndex:1]);
        PhotoViewController *photoController = [[PhotoViewController alloc] init];
        [self.navigationController pushViewController:photoController animated:YES];
        return NO;
        
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
