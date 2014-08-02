//
//  DetailViewController.h
//  u148
//
//  Created by 陈吉诗 on 14-7-22.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Feed;

@interface DetailViewController : UIViewController <UIAlertViewDelegate, UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) Feed *feed;

@end
