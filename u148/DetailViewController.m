//
//  DetailViewController.m
//  u148
//
//  Created by 陈吉诗 on 14-7-22.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "DetailViewController.h"
#import "Feed.h"
#import "User.h"
#import "AFHTTPRequestOperationManager.h"
#import "PhotoViewController.h"
#import "CommentViewController.h"

#define BASE_URL @"http://www.u148.net/json/article/%@"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1];
    
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentButton setImage:[UIImage imageNamed:@"ic_comment.png"] forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(startComment) forControlEvents:UIControlEventTouchUpInside];
    commentButton.frame = CGRectMake(0, 0, 34, 34);
    UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
    
    UIButton *favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [favoriteButton setImage:[UIImage imageNamed:@"ic_favorite.png"] forState:UIControlStateNormal];
    favoriteButton.frame = CGRectMake(0, 0, 34, 34);
    UIBarButtonItem *favoriteItem = [[UIBarButtonItem alloc] initWithCustomView:favoriteButton];
    
    self.navigationItem.rightBarButtonItems = @[commentItem, favoriteItem];

    
    
    NSDictionary *titles = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"首页", [NSNumber numberWithInt:0],
                            @"图画", [NSNumber numberWithInt:3],
                            @"文字", [NSNumber numberWithInt:6],
                            @"杂粹", [NSNumber numberWithInt:7],
                            @"集市", [NSNumber numberWithInt:9],
                            @"漂流", [NSNumber numberWithInt:8],
                            @"游戏", [NSNumber numberWithInt:4],
                            @"影像", [NSNumber numberWithInt:2],
                            @"音频", [NSNumber numberWithInt:5],  nil];
    
    self.navigationController.navigationBar.topItem.title = [titles objectForKey:[NSNumber numberWithInt:self.feed.category]];
    
    self.webview = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.webview.delegate = self;
    [self.view addSubview:self.webview];

    
    [self renderPage:@"正在加载..."];
    
    [self request];
}



- (void)request
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    [manager GET:[NSString stringWithFormat:BASE_URL, self.feed.feedId]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             if ([responseObject isKindOfClass:[NSDictionary class]]) {
                 NSDictionary *dict = (NSDictionary *) responseObject;
                 NSDictionary *data = [dict objectForKey:@"data"];
                 
                 NSString *content = [data objectForKey:@"content"];
                 [self renderPage:content];
                 
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"error %@", error);
         }];
}

- (void)startComment
{
    CommentViewController *commentViewController = [[CommentViewController alloc] init];
    commentViewController.articleId = self.feed.feedId;
    [self.navigationController pushViewController:commentViewController animated:YES];
}

- (void)renderPage:(NSString *)content
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"usite" ofType:@"html" inDirectory:@"html"]];
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"usite" ofType:@"html" inDirectory:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{TITLE}" withString:self.feed.title];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    long createTime = [self.feed.createTime longLongValue];
    NSString *stringFromDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:createTime]];
    NSString *author = [NSString stringWithFormat:@"%@  %@", self.feed.user.nickname, stringFromDate];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{U_AUTHOR}" withString:author];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{U_COMMENT}" withString:[NSString stringWithFormat:@"%i人看过  %i评论", self.feed.browses, self.feed.reviews]];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{CONTENT}" withString:content];
    
    [self.webview loadHTMLString:htmlString baseURL:url];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request URL] absoluteString] hasPrefix:@"ios:"]) {
        
        NSArray *array = [[[request URL] absoluteString] componentsSeparatedByString:@"&"];
        
        NSLog(@"%@", [array objectAtIndex:0]);
        NSLog(@"%@", [array objectAtIndex:1]);
        PhotoViewController *photoController = [[PhotoViewController alloc] init];
        [self.navigationController pushViewController:photoController animated:YES];
        return NO;
        
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
