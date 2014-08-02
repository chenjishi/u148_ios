//
//  User.m
//  u148
//
//  Created by 陈吉诗 on 14-7-19.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "User.h"

#define ALIAS      @"alias"
#define NICKNAME   @"nickName"
#define SEX        @"sex"
#define TOKEN      @"token"
#define ICON       @"icon"

@implementation User

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.alias forKey:ALIAS];
    [encoder encodeObject:self.nickname forKey:NICKNAME];
    [encoder encodeObject:self.sexStr forKey:SEX];
    [encoder encodeObject:self.token forKey:TOKEN];
    [encoder encodeObject:self.icon forKey:ICON];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.alias = [decoder decodeObjectForKey:ALIAS];
        self.nickname = [decoder decodeObjectForKey:NICKNAME];
        self.sexStr = [decoder decodeObjectForKey:SEX];
        self.token = [decoder decodeObjectForKey:TOKEN];
        self.icon = [decoder decodeObjectForKey:ICON];
    }
    
    return self;
}

@end
