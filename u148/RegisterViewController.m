//
//  RegisterViewController.m
//  u148
//
//  Created by 陈吉诗 on 14-8-4.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "RegisterViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "FUIButton.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "UAccountManager.h"
#import "AFHTTPRequestOperationManager.h"

#define URL_REGISTER @"http://www.u148.net/json/register"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1];
    
    //    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
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
    FUIButton *button = [FUIButton buttonWithType:UIButtonTypeCustom];
    button.frame = rect4;
    [button setTitle:@"注  册" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    button.buttonColor = [UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:0/255.0 alpha:1.0];
    button.shadowColor = [UIColor colorWithRed:230.0/255.0 green:138.0/255.0 blue:1/255.0 alpha:1.0];
    button.shadowHeight = 2.0f;
    button.cornerRadius = 4.0f;
    [button addTarget:self action:@selector(onSubmitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
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

- (void)regist:(NSString *)email withPassword:(NSString *)password andName:(NSString *)name
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSDictionary *params = @{@"email" : email, @"password" : password, @"nickname" : name};
    [manager POST:[NSString stringWithFormat:URL_REGISTER]
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if ([responseObject isKindOfClass:[NSDictionary class]]) {
                  NSDictionary *dict = (NSDictionary *) responseObject;
                  
                  int code = [[dict objectForKey:@"code"] intValue];
                  if (code != 0) {
                      NSString *message = [dict objectForKey:@"msg"];
                      [self showToast:message];
                  } else {
                      NSDictionary *data = [dict objectForKey:@"data"];
                      
                      User *user = [[User alloc] init];
                      user.nickname = [data objectForKey:@"nickname"];
                      user.sexStr = [data objectForKey:@"sex"];
                      user.icon = [data objectForKey:@"icon"];
                      user.token = [data objectForKey:@"token"];
                      
                      [[UAccountManager sharedManager] setUserAccount:user];
                      [self showToast:@"注册成功"];
                      
                      [self.navigationController popViewControllerAnimated:YES];
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
