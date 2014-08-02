//
//  User.h
//  u148
//
//  Created by 陈吉诗 on 14-7-19.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *alias;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *sexStr;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *icon;

- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;
@end
