//
//  UAccountManager.h
//  u148
//
//  Created by 陈吉诗 on 14-7-27.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <Foundation/Foundation.h>
@class User;

@interface UAccountManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *accoutDict;

+ (id)sharedManager;
- (BOOL)isLogin;
- (User *)getUserAccount;
- (void)setUserAccount:(User *)user;

@end
