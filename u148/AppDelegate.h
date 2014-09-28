//
//  AppDelegate.h
//  u148
//
//  Created by 陈吉诗 on 14-7-16.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboSDK.h"

@class RootViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, WeiboSDKDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RootViewController *rootViewController;

@end
