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

@interface MenuViewController ()

@end

@implementation MenuViewController
@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    user = [[UAccountManager sharedManager] getUserAccount];
    
    titles = [[NSMutableArray alloc] initWithCapacity:0];
    if (user != nil && user.token.length > 0) {
        [titles addObject:user.nickname];
    } else {
        [titles addObject:@"登陆"];
        [titles addObject:@"注册"];
    }
    
    [titles addObject:@"收藏"];
    [titles addObject:@"反馈"];
    [titles addObject:@"关于"];
    
    self.view.frame = CGRectMake(0, 0, 200, screenHeight - 45 * 6 - 64);
    self.view.backgroundColor = [UIColor colorWithRed:55.0/255.0 green:59.0/255.0 blue:62.0/255.0 alpha:1.0];
    
    UITableView *menuTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    menuTableView.dataSource = self;
    menuTableView.delegate = self;
    menuTableView.backgroundColor = [UIColor clearColor];
    [menuTableView setSeparatorColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0]];
    [menuTableView setSeparatorInset:UIEdgeInsetsZero];
    
    [self.view addSubview:menuTableView];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
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
    
    cell.imageView.image = [UIImage imageNamed:@"ic_info.png"];

    cell.textLabel.text = [titles objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (_delegate) {
        [_delegate onMenuClicked:indexPath.row];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
