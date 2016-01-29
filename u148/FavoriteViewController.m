//
//  FavoriteViewController.m
//  u148
//
//  Created by 陈吉诗 on 14-8-2.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "FavoriteViewController.h"
#import "User.h"
#import "UAccountManager.h"
#import "AFHTTPSessionManager.h"
#import "FavoriteItem.h"
#import "DetailViewController.h"
#import "Feed.h"

#define URL_FAVORITE @"http://api.u148.net/json/get_favourite/0/%d?token=%@"
#define URL_FAVORITE_DELETE @"http://api.u148.net/json/del_favourite?id=%@&token=%@"

@interface FavoriteViewController ()

@end

@implementation FavoriteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1];
    
    self.title = @"收藏";
    
    dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    page = 1;
    
    User *user = [[UAccountManager sharedManager] getUserAccount];
    userToken = user.token;
    
    favoriteTable = [[UITableView alloc]
                     initWithFrame:self.view.frame
                     style:UITableViewStylePlain];
    
    favoriteTable.backgroundColor = [UIColor clearColor];
    favoriteTable.dataSource = self;
    favoriteTable.delegate = self;
    [favoriteTable setSeparatorInset:UIEdgeInsetsMake(0, 8, 0, 8)];
    [favoriteTable setSeparatorColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:0.8f]];
    [self.view addSubview:favoriteTable];
    
    [self request];
}

- (void)request {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:[NSString stringWithFormat:URL_FAVORITE, page, userToken]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if ([responseObject isKindOfClass:[NSDictionary class]] == NO) return;
             
             NSDictionary *dict = (NSDictionary *) responseObject;
             NSDictionary *data = [dict objectForKey:@"data"];
             NSArray *array = [data objectForKey:@"data"];
             
             for (NSDictionary *item in array) {
                 FavoriteItem *favorite = [[FavoriteItem alloc] initWithDictionary:item];
                 [dataArray addObject:favorite];
             }
             
             [favoriteTable reloadData];}
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         }];
}

- (void)deleteFavorite:(NSString *)feedId {
    User *user = [[UAccountManager sharedManager] getUserAccount];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:[NSString stringWithFormat:URL_FAVORITE_DELETE, feedId, user.token]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"favoriteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    FavoriteItem *item = [dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.textLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    
    cell.detailTextLabel.text = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:item.createTime]];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0f/255.0 alpha:1.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    DetailViewController *detailController = [[DetailViewController alloc] init];
    
    FavoriteItem *favoriteItem = [dataArray objectAtIndex:indexPath.row];
    
    Feed *feed = [[Feed alloc] init];
    feed.feedId = favoriteItem.articleId;
    feed.uid = favoriteItem.userId;
    feed.category = favoriteItem.category;
    feed.title = favoriteItem.title;
    feed.createTime = favoriteItem.createTime;
    
    detailController.feed = feed;
    [self.navigationController pushViewController:detailController animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger index = indexPath.row;
        NSString *feedId = [[dataArray objectAtIndex:index] feedId];
        [dataArray removeObjectAtIndex:index];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        [self deleteFavorite:feedId];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
@end
