//
//  Comment.m
//  u148
//
//  Created by 陈吉诗 on 14-7-24.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "Comment.h"
#import "User.h"
#import "NSString+HTML.h"

@implementation Comment

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    if (self) {
        self.commentId = [dict objectForKey:@"id"];
        //remove html tags
        self.contents = [[dict objectForKey:@"contents"] stringByDecodingHTMLEntities];
        
        NSString *content = [[dict objectForKey:@"contents"] stringByDecodingHTMLEntities];
        self.contents = [content stringByReplacingOccurrencesOfString:@"(来自Android客户端)" withString:@""];
        self.contents = [self.contents stringByReplacingOccurrencesOfString:@"(来自iPhone客户端)" withString:@""];
        
        NSDictionary *userObj = [dict objectForKey:@"usr"];
        User *user = [[User alloc] init];
        user.icon = [userObj objectForKey:@"icon"];
        user.alias = [userObj objectForKey:@"alias"];
        user.nickname = [userObj objectForKey:@"nickname"];
        user.sexStr = [userObj objectForKey:@"sexStr"];
        self.user = user;
        
        self.userId = [dict objectForKey:@"uid"];
        self.articleId = [dict objectForKey:@"aid"];
        self.createTime = [dict objectForKey:@"create_time"];
        self.floorNo = [[dict objectForKey:@"floor_no"] intValue];        
    }
    
    return self;
}

@end
