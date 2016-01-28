//
//  MenuViewController.m
//  u148
//
//  Created by 陈吉诗 on 14-7-21.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuCell.h"
#import "UAccountManager.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

#define TAG_LOGIN  1001
#define TAG_REGIST 1002

@interface MenuViewController ()
{
    User *user;
    NSMutableArray *titles;
    NSMutableArray *icons;
    
    UIImageView *avatarView;
    UIButton *loginButton;
    UIButton *registerButton;
    
    UILabel *userLabel;
}

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"road.jpg"];
    CGFloat h = self.view.frame.size.height + 40;
    CGFloat w = 400 * h / 960;
    
    CGSize newSize = CGSizeMake(w, h);
    
    self.view.frame = CGRectMake(0, 0, 200, self.view.frame.size.height);
    self.view.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:image scaledToSize:newSize]];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    avatarView = [[UIImageView alloc] initWithFrame:CGRectMake((200 - 30) / 2.f, 20, 30, 30)];
    avatarView.image = [UIImage imageNamed:@"head.png"];
    [headView addSubview:avatarView];
    
    userLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 58, 200, 20)];
    userLabel.font = [UIFont systemFontOfSize:14.0f];
    userLabel.textAlignment = NSTextAlignmentCenter;
    userLabel.textColor = [UIColor colorWithRed:60.0f/255 green:100.0f/255 blue:90.0f/255 alpha:1.0f];
    userLabel.hidden = YES;
    [headView addSubview:userLabel];
    
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.tag = TAG_LOGIN;
    loginButton.frame = CGRectMake(100 - 10 - 48, 58, 48, 24);
    loginButton.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.3f];
    [loginButton setTitle:@"登陆" forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    loginButton.layer.cornerRadius = 4.0f;
    [loginButton setTitleColor:[UIColor colorWithRed:88.0f/255 green:148.0f/255 blue:133.0f/255 alpha:1.0f] forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor colorWithRed:1.0f green:153.0f/255 blue:0 alpha:1.0f] forState:UIControlStateHighlighted];
    [loginButton addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:loginButton];
    
    registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    registerButton.frame = CGRectMake(100 + 10, 58, 48, 24);
    registerButton.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.3f];
    registerButton.tag = TAG_REGIST;
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    registerButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    registerButton.layer.cornerRadius = 4.0f;
    [registerButton addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setTitleColor:[UIColor colorWithRed:88.0f/255 green:148.0f/255 blue:133.0f/255 alpha:1.0f] forState:UIControlStateNormal];
    [registerButton setTitleColor:[UIColor colorWithRed:1.0f green:153.0f/255 blue:0 alpha:1.0f] forState:UIControlStateHighlighted];
    [headView addSubview:registerButton];
    
    self.tableView.tableHeaderView = headView;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self refreshMenu];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)onButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger tag = button.tag;
    if (self.delegate) {
        [self.delegate onMenuClickedAt:tag];
    }
}

- (void)refreshMenu
{
    user = [[UAccountManager sharedManager] getUserAccount];
    BOOL isLogin = user && user.token.length > 0;
    
    if (isLogin) {
        [avatarView setImageWithURL:[NSURL URLWithString:user.icon]
                   placeholderImage:[UIImage imageNamed:@"user_default.png"]];
        loginButton.hidden = YES;
        registerButton.hidden = YES;
        userLabel.text = user.nickname;
        userLabel.hidden = NO;
    } else {
        avatarView.image = [UIImage imageNamed:@"head.png"];
        [loginButton setTitle:@"登陆" forState:UIControlStateNormal];
        
        userLabel.hidden = YES;
        loginButton.hidden = NO;
        registerButton.hidden = NO;        
    }
    
    titles = [[NSMutableArray alloc] initWithObjects:@"收藏", @"反馈", @"关于", nil];
    icons = [[NSMutableArray alloc] initWithObjects:@"ic_menu1.png", @"ic_menu2.png", @"ic_menu3.png", nil];
    
    if (isLogin) {
        [titles addObject:@"退出"];
        [icons addObject:@"ic_menu4.png"];
    }
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"menuCell";
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSInteger index = indexPath.row;
    
    cell.imageView.image = [UIImage imageNamed:[icons objectAtIndex:index]];
    cell.textLabel.text = [titles objectAtIndex:index];
    
//    if (index == titles.count - 1) {
//        UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, 53, 200, 1)];
//        divider.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.1];
//        [cell.contentView addSubview:divider];
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.delegate) {
        [self.delegate onMenuClickedAt:indexPath.row];
    }
}
@end
