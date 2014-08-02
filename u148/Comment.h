//
//  Comment.h
//  u148
//
//  Created by 陈吉诗 on 14-7-24.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <Foundation/Foundation.h>
@class User;

@interface Comment : NSObject

@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) NSString *contents;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *articleId;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, assign) NSInteger floorNo;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
