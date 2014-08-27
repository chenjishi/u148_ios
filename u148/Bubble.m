//
//  Bubble.m
//  u148
//
//  Created by 陈吉诗 on 14-8-11.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "Bubble.h"

@implementation Bubble

- (id)initWidthDictionary:(NSDictionary *)dict
{
    {
        self = [super init];
        if (self) {
            self.title = [dict objectForKey:@"title"];
            self.image = [dict objectForKey:@"image"];
        }
        
        return self;
    }
}

@end
