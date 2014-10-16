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

#define BASE_URL @"http://api.u148.net/json/%i/%i"

static NSString* const feedCellIdentifier = @"feedCell";

@interface FeedsViewController ()
{
    NSMutableArray *dataArray;
    NSMutableParagraphStyle *paragraphStyle;
    NSDictionary *categories;
    
    UIView *mFootView;
    int page;
}

@end

@implementation FeedsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:4];
    page = 1;
    
    categories = @{@0 : @"首页", @3 : @"图画", @6 : @"文字",
                   @7 : @"杂粹", @9 : @"集市", @8 : @"漂流",
                   @4 : @"游戏", @2 : @"影像", @5 : @"音频",
                   @10 : @"短品"};
    
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setSeparatorColor:[UIColor colorWithRed:225.0f/255 green:225.0f/255 blue:225.0f/255 alpha:1]];
    
    mFootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    mFootView.backgroundColor = [UIColor clearColor];
    mFootView.hidden = YES;
    
    UIButton *footButton = [[UIButton alloc] initWithFrame:mFootView.frame];
    [footButton setTitle:@"加载更多" forState:UIControlStateNormal];
    [footButton setTitleColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0f/255.0 alpha:1.0]
                     forState:UIControlStateNormal];
    [footButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:0/255.0 alpha:1.0]
                     forState:UIControlStateHighlighted];
    footButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [footButton addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
    [mFootView addSubview:footButton];
    self.tableView.tableFooterView = mFootView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:1.0f green:153.0f/255 blue:0 alpha:1.0f];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
}

- (void)refreshTable
{
    page = 1;
    [dataArray removeAllObjects];
    [self request];
}

- (void)requestData
{
    if (dataArray.count == 0) {
        [self request];
    }
}

- (void)loadMore
{
    page++;
    [self request];
}

- (void)request
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:[NSString stringWithFormat:BASE_URL, self.categoryType, page]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             if ([responseObject isKindOfClass:[NSDictionary class]]) {
                 NSDictionary *dict = (NSDictionary *) responseObject;
                 NSDictionary *data = [dict objectForKey:@"data"];
                 NSArray *array = [data objectForKey:@"data"];
                 
                 for (NSDictionary *item in array) {
                     Feed *feed = [[Feed alloc] initWithDictionary:item];
                     [dataArray addObject:feed];
                 }
                 
                 [self.refreshControl endRefreshing];
                 [self.tableView reloadData];

                 if (array.count >= 10) {
                     mFootView.hidden = NO;
                 } else {
                     mFootView.hidden = YES;
                 }
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"error %@", error);
         }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 119.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feed *feed = [dataArray objectAtIndex:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    DetailViewController *detailController = [[DetailViewController alloc] init];
    detailController.feed = feed;
    detailController.titleText = [categories objectForKey:[NSNumber numberWithInteger:feed.category]];
    [self.navigationController pushViewController:detailController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:feedCellIdentifier];
    
    if (!cell) {
        cell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:feedCellIdentifier];
    }
    
    Feed *feed = [dataArray objectAtIndex:indexPath.row];
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:
                                        [NSString stringWithFormat:@"[%@] %@",
                                         [categories objectForKey:[NSNumber numberWithInteger:feed.category]],
                                         feed.title]];
    [title addAttribute:NSForegroundColorAttributeName
                  value:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:0/255.0 alpha:1.0]
                  range:NSMakeRange(0, 4)];
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:feed.picMin] placeholderImage:[UIImage imageNamed:@"ic_place_holder.png"]];
    cell.textLabel.attributedText = title;
    
    
    NSMutableAttributedString *summary = [[NSMutableAttributedString alloc] initWithString:feed.summary];
    [summary addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [feed.summary length])];
    cell.detailTextLabel.attributedText = summary;
    cell.reviewsLabel.text = [NSString stringWithFormat:@"%i人看过  %i评论", feed.browses, feed.reviews];
    
    return cell;
}
@end
