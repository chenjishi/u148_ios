//
//  Feed.h
//  u148
//
//  Created by 陈吉诗 on 14-7-19.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <Foundation/Foundation.h>
@class User;

@interface Feed : NSObject

@property (nonatomic, strong) NSString *feedId;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, assign) NSInteger category;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *picMin;
@property (nonatomic, assign) int star;
@property (nonatomic, assign) long long createTime;
@property (nonatomic, assign) int browses;
@property (nonatomic, assign) int reviews;

@property (nonatomic, strong) User *user;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
