//
//  FavoriteItem.h
//  u148
//
//  Created by 陈吉诗 on 14-8-2.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavoriteItem : NSObject

@property (nonatomic, strong) NSString *feedId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) NSInteger category;
@property (nonatomic, strong) NSString *articleId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) long long createTime;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
