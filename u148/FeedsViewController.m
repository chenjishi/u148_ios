//
//  MainViewController.m
//  u148
//
//  Created by 陈吉诗 on 14-7-16.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "FeedsViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "Feed.h"
#import "UIImageView+AFNetworking.h"
#import "FeedCell.h"
#import "DetailViewController.h"

#define BASE_URL @"http://www.u148.net/json/%i/%i"

@interface FeedsViewController ()

@end

@implementation FeedsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.feeds = [[NSMutableArray alloc] initWithCapacity:0];
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64 - 36);
    
    self.page = 1;
    
    self.categories = [NSDictionary dictionaryWithObjectsAndKeys:
                       @"首页", [NSNumber numberWithInt:0],
                       @"图画", [NSNumber numberWithInt:3],
                       @"文字", [NSNumber numberWithInt:6],
                       @"杂粹", [NSNumber numberWithInt:7],
                       @"集市", [NSNumber numberWithInt:9],
                       @"漂流", [NSNumber numberWithInt:8],
                       @"游戏", [NSNumber numberWithInt:4],
                       @"影像", [NSNumber numberWithInt:2],
                       @"音频", [NSNumber numberWithInt:5],  nil];
    
    self.feedsTable = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.feedsTable.backgroundColor = [UIColor clearColor];
    self.feedsTable.dataSource = self;
    self.feedsTable.delegate = self;
    [self.feedsTable setSeparatorInset:UIEdgeInsetsZero];
    [self.feedsTable setSeparatorColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1]];
    [self.view addSubview:self.feedsTable];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.feedsTable.frame.size.width, 44.0f)];
    footView.backgroundColor = [UIColor clearColor];
    
    UIButton *footButton = [[UIButton alloc] initWithFrame:footView.frame];
    [footButton setTitle:@"加载更多" forState:UIControlStateNormal];
    [footButton setTitleColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0f/255.0 alpha:1.0]
                     forState:UIControlStateNormal];
    footButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [footButton addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:footButton];
    
    self.feedsTable.tableFooterView = footView;
    
    [self request];
}

- (void)loadMore
{
    self.page++;
    [self request];
}

- (void)request
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    [manager GET:[NSString stringWithFormat:BASE_URL, self.categoryType, self.page]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             if ([responseObject isKindOfClass:[NSDictionary class]]) {
                 NSDictionary *dict = (NSDictionary *) responseObject;
                 NSDictionary *data = [dict objectForKey:@"data"];
                 NSArray *array = [data objectForKey:@"data"];
                 
                 for (NSDictionary *item in array) {
                     Feed *feed = [[Feed alloc] initWithDictionary:item];
                     [self.feeds addObject:feed];
                 }
                 
                 [self.feedsTable reloadData];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"error %@", error);
         }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.feeds.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 103.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    DetailViewController *detailController = [[DetailViewController alloc] init];
    detailController.feed = [self.feeds objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"feedCell";
    
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    Feed *feed = [self.feeds objectAtIndex:indexPath.row];
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:
                                        [NSString stringWithFormat:@"[%@] %@",
                                         [self.categories objectForKey:[NSNumber numberWithInt:feed.category]],
                                         feed.title]];
    [title addAttribute:NSForegroundColorAttributeName
                  value:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:0/255.0 alpha:1.0]
                  range:NSMakeRange(0, 4)];
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:feed.picMin] placeholderImage:[UIImage imageNamed:@"icon.png"]];
    cell.textLabel.attributedText = title;
    cell.detailTextLabel.text = feed.summary;
    cell.reviewsLabel.text = [NSString stringWithFormat:@"%i人看过  %i评论", feed.browses, feed.reviews];
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
