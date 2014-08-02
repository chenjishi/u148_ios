//
//  Feed.m
//  u148
//
//  Created by 陈吉诗 on 14-7-19.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "Feed.h"
#import "User.h"

@implementation Feed

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.feedId = [dict objectForKey:@"id"];
        self.uid = [dict objectForKey:@"uid"];
        self.category = [[dict objectForKey:@"category"] intValue];
        self.title = [dict objectForKey:@"title"];
        self.summary = [dict objectForKey:@"summary"];
        self.picMin = [dict objectForKey:@"pic_min"];
        self.star = [[dict objectForKey:@"star"] intValue];
        self.createTime = [dict objectForKey:@"create_time"];
        self.browses = [[dict objectForKey:@"count_browse"] intValue];
        self.reviews = [[dict objectForKey:@"count_review"] intValue];
        
        NSDictionary *userObj = [dict objectForKey:@"usr"];
        User *user = [[User alloc] init];
        user.alias = [userObj objectForKey:@"alias"];
        user.nickname = [userObj objectForKey:@"nickname"];
        user.sexStr = [userObj objectForKey:@"sexStr"];
        
        self.user = user;
    }
    
    return self;
}

@end
