//
//  SearchViewController.m
//  u148
//
//  Created by 陈吉诗 on 15/2/4.
//  Copyright (c) 2015年 u148. All rights reserved.
//

#import "SearchViewController.h"
#import "UIImage+Color.h"
#import "AFHTTPSessionManager.h"
#import "Feed.h"
#import "FeedCell.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"
#import "UIImageView+AFNetworking.h"
#import "DetailViewController.h"
#import "UIImage+Color.h"
#import "SurprizeViewController.h"
#import "Flurry.h"

#define TAG_SEARCH_FIELD 102
#define TAG_TABLE_VIEW   103
#define TAG_FOOT_VIEW    104

static NSString* const feedCellIdentifier = @"feedCell";

@implementation SearchViewController {
    NSUInteger currentPage;
    NSString *keyword;
    NSDictionary *categories;
    NSMutableParagraphStyle *paragraphStyle;
    
    NSMutableArray *dataArray;
    
    NSInteger clickCount;
    
    MBProgressHUD *progress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1];
    self.navigationController.navigationBar.topItem.title = @"";
    self.title = @"搜索";
    
    currentPage = 1;
    paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:4];
    dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    categories = @{@0 : @"首页", @3 : @"图画", @6 : @"文字",
                   @7 : @"杂粹", @9 : @"集市", @8 : @"漂流",
                   @4 : @"游戏", @2 : @"影像", @5 : @"音频",
                   @10 : @"短品"};
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 44)];
    paddingView.backgroundColor = [UIColor clearColor];
    
    CGRect rect = CGRectMake(8, 84, self.view.frame.size.width - 16 - 8 - 60, 44);
    UITextField *textField = [[UITextField alloc] initWithFrame:rect];
    textField.tag = TAG_SEARCH_FIELD;
    textField.delegate = self;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.backgroundColor = [UIColor whiteColor];
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.layer.borderWidth = 1;
    textField.layer.cornerRadius = 2.0f;
    textField.layer.borderColor = [[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:0.8f] CGColor];
    textField.returnKeyType = UIReturnKeyDone;
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:textField];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(rect.origin.x + rect.size.width + 8, rect.origin.y + 2, 60, 40);
    CALayer *layer = [button layer];
    button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:2.0f];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"搜索" forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:255.0f/255 green:153.0f/255 blue:0 alpha:1.0f]]
                      forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:212.0f/255 green:128.0f/255 blue:0 alpha:1.0f]]
                      forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(onSearchClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    footView.backgroundColor = [UIColor clearColor];
    footView.tag = TAG_FOOT_VIEW;
    footView.hidden = YES;
    
    UIButton *footButton = [[UIButton alloc] initWithFrame:footView.frame];
    [footButton setTitle:@"加载更多" forState:UIControlStateNormal];
    [footButton setTitleColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0f/255.0 alpha:1.0]
                     forState:UIControlStateNormal];
    [footButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:0/255.0 alpha:1.0]
                     forState:UIControlStateHighlighted];
    footButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [footButton addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:footButton];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, rect.origin.y + rect.size.height + 12,
                                                                           self.view.frame.size.width,
                                                                           self.view.frame.size.height - (rect.origin.y + rect.size.height + 12))
                                                          style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    [tableView setSeparatorColor:[UIColor colorWithRed:225.0f/255 green:225.0f/255 blue:225.0f/255 alpha:1]];
    tableView.tag = TAG_TABLE_VIEW;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = footView;
    [self.view addSubview:tableView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((self.view.frame.size.width - 50.f) / 2, self.view.frame.size.height - 60.f, 50.f, 50.f);
    [btn setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:204.f / 255.f green:204.f / 255.f blue:204.f / 255.f alpha:0.4f]] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(onButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)onButtonClicked {
    [Flurry logEvent:@"easter_egg_clicked"];
    
    clickCount += 1;
    if (clickCount == 8) {
        [Flurry logEvent:@"easter_egg_triggered"];
        clickCount = 0;
        SurprizeViewController *surprizeController = [[SurprizeViewController alloc] init];        
        [self presentViewController:surprizeController animated:YES completion:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return NO;
}

- (void)loadMore {
    currentPage++;
    [self request];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [progress removeFromSuperview];
    progress = nil;
}

- (void)request {
    progress = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progress];
    progress.delegate = self;
    [progress show:YES];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    keyword = [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [manager GET:[NSString stringWithFormat:@"http://api.u148.net/json/search/%ld?keyword=%@", currentPage, keyword]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             [progress hide:YES];
             
             if ([responseObject isKindOfClass:[NSDictionary class]] == NO) return;
             
             NSDictionary *dict = (NSDictionary *) responseObject;
             NSDictionary *data = [dict objectForKey:@"data"];
             NSArray *array = [data objectForKey:@"data"];
             for (NSDictionary *item in array) {
                 Feed *feed = [[Feed alloc] initWithDictionary:item];
                 [dataArray addObject:feed];
             }
             
             UIView *footView = [self.view viewWithTag:TAG_FOOT_VIEW];
             footView.hidden = array.count < 10;
             
             UITableView *tableView = (UITableView *) [self.view viewWithTag:TAG_TABLE_VIEW];
             [tableView reloadData];}
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             [progress hide:YES];
         }];
}

- (void)onSearchClicked {
    currentPage = 1;

    [dataArray removeAllObjects];
    UITableView *tableView = (UITableView *) [self.view viewWithTag:TAG_TABLE_VIEW];
    [tableView reloadData];
    
    UITextField *textField = (UITextField *) [self.view viewWithTag:TAG_SEARCH_FIELD];
    NSString *text = textField.text;
    
    if (text && text.length > 0) {
        keyword = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self request];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 119.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Feed *feed = [dataArray objectAtIndex:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    DetailViewController *detailController = [[DetailViewController alloc] init];
    detailController.feed = feed;
    detailController.titleText = [categories objectForKey:[NSNumber numberWithInteger:feed.category]];
    [self.navigationController pushViewController:detailController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    
    NSString *imageUrl = feed.picMin;
    if ([imageUrl hasSuffix:@".gif"]) {
        FLAnimatedImage *__block animatedImage = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *url = [NSURL URLWithString:imageUrl];
            NSData *data = [NSData dataWithContentsOfURL:url];
            animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.postImage.animatedImage = animatedImage;
            });
        });
    } else {
        [cell.postImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"ic_place_holder"]];
    }
    
    cell.textLabel.attributedText = title;
    NSMutableAttributedString *summary = [[NSMutableAttributedString alloc] initWithString:feed.summary];
    [summary addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [feed.summary length])];
    cell.detailTextLabel.attributedText = summary;
    cell.reviewsLabel.text = [NSString stringWithFormat:@"%i人看过  %i评论", feed.browses, feed.reviews];
    
    return cell;
}
@end
