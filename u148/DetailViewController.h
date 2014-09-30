//
//  DetailViewController.h
//  u148
//
//  Created by 陈吉诗 on 14-7-22.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareView.h"
@class Feed;

@interface DetailViewController : UIViewController <UIAlertViewDelegate, UIWebViewDelegate, ShareDelegate>

{
    NSDictionary *tags;
    
    UIWebView *webView;
    ShareView *shareView;
    
    BOOL isShareViewShowed;
}

@property (nonatomic, strong) Feed *feed;
@property (nonatomic, strong) NSString *titleText;

@end
