//
//  DetailViewController.h
//  u148
//
//  Created by 陈吉诗 on 14-7-22.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomIOS7AlertView.h"
@class Feed;

@interface DetailViewController : UIViewController <CustomIOS7AlertViewDelegate, UIAlertViewDelegate, UIWebViewDelegate>
{
    NSDictionary *tags;
    CustomIOS7AlertView *shareDialog;
    
    UIWebView *webView;
    
    int weixinScene;
}

@property (nonatomic, strong) Feed *feed;

@end
