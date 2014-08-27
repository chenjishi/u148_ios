//
//  Bubble.h
//  u148
//
//  Created by 陈吉诗 on 14-8-11.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bubble : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *image;

- (id)initWidthDictionary:(NSDictionary *)dict;

@end
