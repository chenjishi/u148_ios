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
#import "WXApi.h"
#import "UIImageView+AFNetworking.h"

#define BASE_URL @"http://api.u148.net/json/article/%@"
#define URL_FAVORITE_ADD @"http://api.u148.net/json/favourite?id=%@&token=%@"
#define LOGIN_URL @"http://api.u148.net/json/login"

#define TAG_SHARE_SESSION 101
#define TAG_SHARE_FRIENDS 102

@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize feed = _feed;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor colorWithRed:246.0f/255 green:246.0f/255 blue:246.0f/255 alpha:1.0f];
    
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentButton setImage:[UIImage imageNamed:@"ic_nav_cmt.png"] forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(startComment) forControlEvents:UIControlEventTouchUpInside];
    commentButton.frame = CGRectMake(0, 0, 26, 26);
    UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
    
    UIButton *favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [favoriteButton setImage:[UIImage imageNamed:@"ic_nav_favorite.png"] forState:UIControlStateNormal];
    favoriteButton.frame = CGRectMake(0, 0, 26, 26);
    [favoriteButton addTarget:self action:@selector(onFavoriteButtonCliked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *favoriteItem = [[UIBarButtonItem alloc] initWithCustomView:favoriteButton];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setImage:[UIImage imageNamed:@"ic_nav_share.png"] forState:UIControlStateNormal];
    shareButton.frame = CGRectMake(0, 0, 26, 26);
    [shareButton addTarget:self action:@selector(onShareButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    
    self.navigationItem.rightBarButtonItems = @[commentItem, favoriteItem, shareItem];
    
    tags = [NSDictionary dictionaryWithObjectsAndKeys:
            @"首页", [NSNumber numberWithInt:0],
            @"图画", [NSNumber numberWithInt:3],
            @"文字", [NSNumber numberWithInt:6],
            @"杂粹", [NSNumber numberWithInt:7],
            @"集市", [NSNumber numberWithInt:9],
            @"漂流", [NSNumber numberWithInt:8],
            @"游戏", [NSNumber numberWithInt:4],
            @"影像", [NSNumber numberWithInt:2],
            @"音频", [NSNumber numberWithInt:5],  nil];
    
    self.navigationController.navigationBar.topItem.title = [tags objectForKey:[NSNumber numberWithInt:self.feed.category]];
    
    
    webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    webView.delegate = self;
    [self.view addSubview:webView];
    
    [WXApi registerApp:@"wxf862baa09e0df157" withDescription:@"有意思吧"];
    
    
    [self renderPage:@"正在加载..."];
    
    weixinScene = 0;
    
    [self request];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"";
}

- (void)onShareButtonClicked
{
    [self showShareDialog];
}

- (void)shareToWeixin:(id)sender
{
    UIButton *button = (UIButton*) sender;
    int scene = button.tag;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_feed.picMin]]
                     placeholderImage:[UIImage imageNamed:@"ic_place_holder.png"]
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  [self sendToWeixin:image withType:scene];
                              }
                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                              }];
    [shareDialog close];
}

- (void)showShareDialog
{
    if (!shareDialog) {
        shareDialog = [[CustomIOS7AlertView alloc] init];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
        
        UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 70, 70)];
        button1.tag = TAG_SHARE_SESSION;
        [button1 setImage:[UIImage imageNamed:@"ic_session.png"] forState:UIControlStateNormal];
        [button1 addTarget:self action:@selector(shareToWeixin:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button1];
        
        UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(110, 20, 70, 70)];
        button2.tag = TAG_SHARE_FRIENDS;
        [button2 setImage:[UIImage imageNamed:@"ic_friend.png"] forState:UIControlStateNormal];
        [button2 addTarget:self action:@selector(shareToWeixin:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button2];
        
        [shareDialog setContainerView:view];
        [shareDialog setButtonTitles:[NSArray arrayWithObject:@"关闭"]];
        [shareDialog setUseMotionEffects:YES];
        [shareDialog setDelegate:self];
    }
    
    [shareDialog show];
}

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [shareDialog close];
}

- (void)sendToWeixin:(UIImage *) image withType:(int)scene
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = _feed.title;
    message.description = _feed.summary;
    [message setThumbImage:image];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = [NSString stringWithFormat:@"http://www.u148.net/article/%@.html", _feed.feedId];
    
    message.mediaObject = ext;
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene == TAG_SHARE_SESSION ? WXSceneSession : WXSceneTimeline;
    
    [WXApi sendReq:req];
    
    [shareDialog close];
}

- (void)request
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
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
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *params = @{@"email" : name, @"password" : password};
    [manager POST:[NSString stringWithFormat:LOGIN_URL]
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
              }}
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:[NSString stringWithFormat:URL_FAVORITE_ADD, _feed.feedId, userToken]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [self showToast:@"已移入收藏夹"];}
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self showToast:@"服务器繁忙，请稍后再试"];}
     ];
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
    
    [webView loadHTMLString:htmlString baseURL:url];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request URL] absoluteString] hasPrefix:@"ios:"]) {
        
        NSArray *array = [[[request URL] absoluteString] componentsSeparatedByString:@"&"];
        
        PhotoViewController *photoController = [[PhotoViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoController];
        photoController.imageUrl = [array objectAtIndex:1];
        [self presentViewController:nav animated:YES completion:nil];
        return NO;
        
    }
    return YES;
}

@end
