//
//  RootViewController.m
//  u148
//
//  Created by 陈吉诗 on 14-7-20.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "RootViewController.h"
#import "MenuViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "User.h"
#import "UAccountManager.h"
#import "MBProgressHUD.h"
#import "FavoriteViewController.h"
#import "CustomIOS7AlertView.h"
#import "SurprizeViewController.h"
#import "RegisterViewController.h"
#import "FeedsViewController.h"
#import "TabIndicator.h"
#import "SearchViewController.h"

#define LOGIN_URL @"http://api.u148.net/json/login"

#define TAB_VIEW_TAG  200


@interface RootViewController ()

@end

@implementation RootViewController

@synthesize scrollView = _scrollView, controllers = _controllers, contentView = _contentView;

- (id) initWithViewControllers:(NSArray *)controllers
{
    if (self = [super init]) {
        _controllers = controllers;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"ic_nav_menu.png"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    menuButton.frame = CGRectMake(0, 0, 26, 26);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setImage:[UIImage imageNamed:@"ic_nav_search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(startSearch) forControlEvents:UIControlEventTouchUpInside];
    searchButton.frame = CGRectMake(0, 0, 26, 26);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
        
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    _contentView.backgroundColor = [UIColor colorWithRed:246.0f/255 green:246.0f/255 blue:246.0f/255 alpha:1.0f];
    [self.view addSubview:_contentView];
    
    tabIndex = 0;
    
    //prevent scrollview's add top space
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tabGroupView = [[TabGroupView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 36)];
    [self.tabGroupView setIndexAt:tabIndex];
    self.tabGroupView.tabDelegate = self;
    [_contentView addSubview:self.tabGroupView];
    
    CGRect rect = CGRectMake(0, 36, self.view.frame.size.width, _contentView.frame.size.height - 36);
    _scrollView = [[UIScrollView alloc] initWithFrame:rect];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.contentSize = CGSizeMake(_controllers.count * rect.size.width, rect.size.height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.autoresizesSubviews = NO;
    _scrollView.autoresizingMask = UIViewAutoresizingNone;
    [_contentView addSubview:self.scrollView];
    
    for (UIViewController *viewControllers in self.controllers) {
        [self.scrollView addSubview:viewControllers.view];
        [self addChildViewController:viewControllers];
    }
    
    self.menuViewController = [[MenuViewController alloc] init];
    self.menuViewController.delegate = self;
    self.menuViewController.view.frame = CGRectMake(-200, 64, 200, self.view.frame.size.height - 64);
    
    isMenuShow = NO;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu)];
    
    [self refreshTableView:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"有意思吧";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.menuViewController refreshMenu];
    tabScrollView.contentSize = CGSizeMake(tabWidth * tabCount, 36);

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
                  [self.menuViewController refreshMenu];
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

- (void)onTabClicked:(NSUInteger)index
{
    if (tabIndex != index) {
        tabIndex = index;
        
        [self.tabGroupView setIndexAt:tabIndex];
        
        CGRect frame = _scrollView.frame;
        frame.origin.x = frame.size.width * tabIndex;
        [_scrollView scrollRectToVisible:frame animated:YES];
        
        [self refreshTableView:tabIndex];
    }
}

- (void)onMenuClicked:(NSUInteger)index
{
    User *user = [[UAccountManager sharedManager] getUserAccount];
    BOOL isLogin = user && user.token.length > 0;
    
    if (index == 1001) {
        [self showLoginDialog];
    }
    
    if (index == 1002) {
        [self openRegister];
    }
    
    if (index == 0) {
        if (isLogin) {
            [self openFavoriteController];
        } else {
            [self showLoginDialog];
        }
    }
    
    if (index == 1) {
        [self sendFeedBack];
    }
    
    if (index == 2) {
        [self showAboutDialog];
    }
    
    if (index == 3) {
        user.token = @"";
        [[UAccountManager sharedManager] setUserAccount:user];
        [self showToast:@"账号已退出"];
        [self.menuViewController refreshMenu];
    }
    
    [self hideMenu];
}

- (void)openRegister
{
    RegisterViewController *registerController = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerController animated:YES];
}

- (void)sendFeedBack
{
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    
    if ([MFMailComposeViewController canSendMail]) {
        NSString *sdkVersion = [[UIDevice currentDevice] systemVersion];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSArray *recipents = [NSArray arrayWithObjects:@"webmaster@u148.net", @"chenjishi313@gmail.com", nil];
        
        mailController.mailComposeDelegate = self;
        [mailController setSubject:[NSString stringWithFormat:@"有意思吧意见反馈(iOS:%@,version:%@)", sdkVersion, version]];
        [mailController setToRecipients:recipents];
        
        [self presentViewController:mailController animated:YES completion:NULL];
    } else {
        [self showToast:@"请先配置您的邮箱账号"];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)openFavoriteController
{
    FavoriteViewController *favoriteController = [[FavoriteViewController alloc] init];
    [self.navigationController pushViewController:favoriteController animated:YES];
}

- (void)hideMenu
{
    [UIView animateWithDuration:0.3 animations:^{
        _contentView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
        self.menuViewController.view.frame = CGRectMake(-200, 64, 200, self.view.frame.size.height - 64);
    } completion:^(BOOL finished) {
        [_contentView removeGestureRecognizer:tapRecognizer];
        [self.menuViewController.view removeFromSuperview];
        isMenuShow = NO;
    }];
}

- (void)startSearch
{
    SearchViewController *viewController = [[SearchViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)showMenu
{
    [self.view insertSubview:self.menuViewController.view aboveSubview:_contentView];
    [UIView animateWithDuration:0.3 animations:^{
        if (isMenuShow) {
            _contentView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
            self.menuViewController.view.frame = CGRectMake(-200, 64, 200, self.view.frame.size.height - 64);
            [_contentView removeGestureRecognizer:tapRecognizer];
        } else{
            CGRect rect = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
            _contentView.frame = CGRectOffset(rect, 200, 0);
            self.menuViewController.view.frame = CGRectMake(0, 64, 200, self.view.frame.size.height - 64);
            [_contentView addGestureRecognizer:tapRecognizer];
        }
    } completion:^(BOOL finished) {
        if (isMenuShow) {
            [self.menuViewController.view removeFromSuperview];
        }
        isMenuShow = !isMenuShow;
    }];
}

- (void)showAboutDialog
{
    aboutDialog = [[CustomIOS7AlertView alloc] init];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 8, 240, 190)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_logo_big.png"]];
    imageView.frame = CGRectMake(70, 20, 100, 96);
    [view addSubview:imageView];
    
    UIButton *versionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [versionButton setTitle:version forState:UIControlStateNormal];
    versionButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [versionButton addTarget:self action:@selector(onVersionClicked) forControlEvents:UIControlEventTouchUpInside];
    [versionButton setTitleColor:[UIColor colorWithRed:153.0f/255 green:153.0f/255 blue:153.0f/255 alpha:1.0f]
                        forState:UIControlStateNormal];
    versionButton.frame = CGRectMake(100, imageView.frame.size.height + imageView.frame.origin.y + 10, 40, 20);
    [view addSubview:versionButton];
    
    CGFloat y = versionButton.frame.origin.y + versionButton.frame.size.height + 16;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 240, 0)];
    label.text = @"©2007 - 2019 Www.U148.Net";
    label.textColor = [UIColor colorWithRed:153.0f/255 green:153.0f/255 blue:153.0f/255 alpha:1.0f];
    label.font = [UIFont systemFontOfSize:12.0f];
    [label sizeToFit];
    [view addSubview:label];
    
    CGFloat x = (240 - label.frame.size.width) / 2.0f;
    label.frame = CGRectMake(x, y, 0, 0);
    [label sizeToFit];
    
    [aboutDialog setContainerView:view];
    [aboutDialog setButtonTitles:[NSArray arrayWithObject:@"关闭"]];
    [aboutDialog setUseMotionEffects:YES];
    
    [aboutDialog setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        [alertView close];
    }];
    
    [aboutDialog show];
}

- (void)onVersionClicked
{
    clickCount += 1;
    if (clickCount == 8) {
        clickCount = 0;
        SurprizeViewController *surprizeController = [[SurprizeViewController alloc] init];
        
        [self presentViewController:surprizeController animated:YES completion:nil];
        [aboutDialog close];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    for (UIViewController *viewController in self.controllers) {
        NSUInteger index = [self.controllers indexOfObject:viewController];
        CGRect frame = viewController.view.frame;
        frame.origin.x = self.view.frame.size.width * index;
        frame.origin.y = 0;
        frame.size.height = self.view.frame.size.height - 64 - 36;
        viewController.view.frame = frame;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSUInteger index = floor(scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5);
    if (index != tabIndex) {
        tabIndex = index;
        [self.tabGroupView setIndexAt:index];
        [self refreshTableView:index];
    }
}

- (void)refreshTableView:(NSUInteger)index
{
    FeedsViewController *feedController = [_controllers objectAtIndex:index];
    if (feedController) {
        [feedController requestData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; 
}
@end
