//
//  RegisterViewController.m
//  u148
//
//  Created by 陈吉诗 on 14-8-4.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "RegisterViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "UAccountManager.h"
#import "AFHTTPSessionManager.h"
#import "PrivacyViewController.h"
#import "UIImage+Color.h"

@interface RegisterViewController ()
{
    UITextField *emailField;
    UITextField *passwordField;
    UITextField *nameField;
}

@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1];
    self.navigationController.navigationBar.topItem.title = @"";
    
    self.title = @"用户注册";
    
    CGRect rect1 = CGRectMake(8, 84, self.view.frame.size.width - 16, 44);
    emailField = [self generateTextField:rect1];
    emailField.placeholder = @"邮箱";
    emailField.leftView = [self generatePaddingView];
    [self.view addSubview:emailField];
    
    CGRect rect2 = CGRectMake(8, rect1.origin.y + rect1.size.height + 8, self.view.frame.size.width - 16, 44);
    passwordField = [self generateTextField:rect2];
    passwordField.placeholder = @"6 ~ 16位密码";
    passwordField.leftView = [self generatePaddingView];
    [self.view addSubview:passwordField];
    
    CGRect rect3 = CGRectMake(8, rect2.origin.y + rect2.size.height + 8, self.view.frame.size.width - 16, 44);
    nameField = [self generateTextField:rect3];
    nameField.placeholder = @"昵称，不超过25字，中文不超过12字";
    nameField.leftView = [self generatePaddingView];
    [self.view addSubview:nameField];
    
    CGRect rect4 = CGRectMake(8, rect3.origin.y + rect3.size.height + 16, self.view.frame.size.width - 16, 44);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = rect4;
    CALayer *layer = [button layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:4.0f];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"完  成" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:255.0f/255 green:153.0f/255 blue:0 alpha:1.0f]]
                      forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:212.0f/255 green:128.0f/255 blue:0 alpha:1.0f]]
                      forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(onSubmitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, rect4.origin.y + rect4.size.height + 8, self.view.frame.size.width - 32, 12)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:102.0f/255 green:102.0f/255 blue:102.0f/255 alpha:1.0f];
    label.text = @"点击「完成」按钮，代表你已阅读并同意";
    [self.view addSubview:label];
    
    UIButton *privacyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    privacyButton.frame = CGRectMake((self.view.frame.size.width - 80) / 2,
                                     label.frame.size.height + label.frame.origin.y + 16, 80, 14.f);
    [privacyButton setTitle:@"注册条款" forState:UIControlStateNormal];
    privacyButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [privacyButton setTitleColor:[UIColor colorWithRed:51.0f/255 green:102.0f/255 blue:153.0f/255 alpha:1.0f]
                        forState:UIControlStateNormal];
    [privacyButton addTarget:self action:@selector(onPrivacyClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:privacyButton];
}

- (void)onPrivacyClicked
{
    PrivacyViewController *viewController = [[PrivacyViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)onSubmitButtonClicked
{
    NSString *email = emailField.text;
    if (email == nil || email.length == 0) {
        [self showToast:@"邮箱不能为空"];
        return;
    }
    
    if (![self isValidEmail:email]) {
        [self showToast:@"邮箱格式不对哦~"];
        return;
    }
    
    NSString *password = passwordField.text;
    if (password == nil || password.length == 0) {
        [self showToast:@"密码不可以为空的哦"];
        return;
    }
    
    if (password.length < 6 || password.length >= 16) {
        [self showToast:@"密码长度需要6位并且小于16位"];
        return;
    }
    
    NSString *name = nameField.text;
    if (name == nil || name.length == 0) {
        [self showToast:@"请输入昵称"];
        return;
    }
    
    if (name.length >= 25) {
        [self showToast:@"昵称太长，中文请限制在12字内，英文25字母内"];
        return;
    }
    
    [self regist:email withPassword:password andName:name];
}

- (void)regist:(NSString *)email withPassword:(NSString *)password andName:(NSString *)name {
    NSDictionary *params = @{@"email" : [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                             @"password" : [password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                             @"nickname" : [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                             @"client" : @"iPhone"};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:@"http://api.u148.net/json/register"
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              if ([responseObject isKindOfClass:[NSDictionary class]] == NO) return;
              
              NSDictionary *dict = (NSDictionary *) responseObject;
              int code = [[dict objectForKey:@"code"] intValue];
              if (code != 0) {
                  NSString *message = [dict objectForKey:@"msg"];
                  [self showToast:message];
              } else {
                  User *user = [[User alloc] initWithDictionary:[dict objectForKey:@"data"]];
                  [[UAccountManager sharedManager] setUserAccount:user];
                  [self showToast:@"注册成功"];
                  [self.navigationController popViewControllerAnimated:YES];
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              [self showToast:@"注册失败，请稍后再试"];
          }];
}

- (BOOL)isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (UIView *)generatePaddingView
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 44)];
}

- (UITextField *)generateTextField:(CGRect)rect
{
    UITextField *textField = [[UITextField alloc] initWithFrame:rect];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.backgroundColor = [UIColor clearColor];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.delegate = self;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.layer.borderWidth = 1;
    textField.layer.borderColor = [[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:0.8f] CGColor];
    
    return textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [emailField resignFirstResponder];
    [passwordField resignFirstResponder];
    [nameField resignFirstResponder];
    
    return YES;
}

- (void)showToast:(NSString *)tips
{
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.mode = MBProgressHUDModeText;
    hud.labelText = tips;
    
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:2];
}
@end
