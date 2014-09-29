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

#define TAG_LOGIN 1001
#define TAG_REGIST 1002

@interface MenuViewController ()
{
    User *user;
    NSArray *titles;
    NSArray *icons;
    
    UIImageView *avatarView;
    UIButton *loginButton;
}

@end

@implementation MenuViewController
@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0, 0, 200, self.view.frame.size.height);
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"flowers.jpg"]];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    avatarView = [[UIImageView alloc] initWithFrame:CGRectMake((200 - 30) / 2.f, 20, 30, 30)];
    avatarView.image = [UIImage imageNamed:@"head.png"];
    [headView addSubview:avatarView];
    
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.tag = TAG_LOGIN;
    loginButton.frame = CGRectMake(100 - 5 - 48, 58, 48, 24);
    [loginButton setTitle:@"登陆" forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor colorWithRed:1.0f green:153.0f/255 blue:0 alpha:1.0f] forState:UIControlStateHighlighted];
    [loginButton addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:loginButton];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100 - 5, 58, 10, 24)];
    label.text = @"/";
    label.font = [UIFont boldSystemFontOfSize:16.f];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [headView addSubview:label];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(100 + 5, 58, 48, 24);
    button2.tag = TAG_REGIST;
    [button2 setTitle:@"注册" forState:UIControlStateNormal];
    button2.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    [button2 addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor colorWithRed:1.0f green:153.0f/255 blue:0 alpha:1.0f] forState:UIControlStateHighlighted];
    [headView addSubview:button2];
    
    self.tableView.tableHeaderView = headView;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    titles = @[@"收藏", @"反馈", @"关于"];
    icons = @[@"ic_nav_favorite", @"ic_feedback.png", @"ic_info.png"];
    
    [self.tableView reloadData];
    
    [self refreshMenu];
}

- (void)onButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSUInteger tag = button.tag;
    if (_delegate) {
        [_delegate onMenuClicked:tag];
    }
}

- (void)refreshMenu
{
    user = [[UAccountManager sharedManager] getUserAccount];
    BOOL isLogin = user && user.token.length > 0;
    
    if (isLogin) {
        [avatarView setImageWithURL:[NSURL URLWithString:user.icon]
                   placeholderImage:[UIImage imageNamed:@"user_default.png"]];
        [loginButton setTitle:@"退出" forState:UIControlStateNormal];
    } else {
        avatarView.image = [UIImage imageNamed:@"head.png"];
        [loginButton setTitle:@"登陆" forState:UIControlStateNormal];
    }
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
    
    if (index == titles.count - 1) {
        UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, 53, 200, 1)];
        divider.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.1];
        [cell.contentView addSubview:divider];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (_delegate) {
        [_delegate onMenuClicked:indexPath.row];
    }
}
@end
