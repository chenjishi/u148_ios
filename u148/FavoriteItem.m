//
//  FavoriteItem.m
//  u148
//
//  Created by 陈吉诗 on 14-8-2.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "FavoriteItem.h"

@implementation FavoriteItem

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.feedId = [dict objectForKey:@"id"];
        self.userId = [dict objectForKey:@"uid"];
        self.category = [[dict objectForKey:@"category"] intValue];
        self.articleId = [dict objectForKey:@"aid"];
        self.title = [dict objectForKey:@"title"];
        self.url = [dict objectForKey:@"url"];
        self.createTime = [[dict valueForKey:@"create_time"] longLongValue];
    }
    
    return self;
}

@end
