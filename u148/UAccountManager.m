//
//  UAccountManager.m
//  u148
//
//  Created by 陈吉诗 on 14-7-27.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "UAccountManager.h"
#import "User.h"

static UAccountManager *sharedInstance = nil;

@interface UAccountManager(Private)
- (void)_saveAccountInfoToFile;
- (void)_loadAccountInfoFromFile;
- (NSString *)_getSavePath;
@end

@implementation UAccountManager

- (BOOL)isLogin
{
    return [self.accoutDict count] > 0;
}

- (User *)getUserAccount
{
    return [self.accoutDict objectForKey:@"user"];
}

- (void)setUserAccount:(User *)user
{
    [self.accoutDict setObject:user forKey:@"user"];
    [self _saveAccountInfoToFile];
}

-(NSString *)_getSavePath
{
    return [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"account.plist"];
}

-(void)_saveAccountInfoToFile
{
    [NSKeyedArchiver archiveRootObject:self.accoutDict toFile:[self _getSavePath]];
}

-(void)_loadAccountInfoFromFile
{
    self.accoutDict = [NSKeyedUnarchiver unarchiveObjectWithFile:[self _getSavePath]];
    if (![self.accoutDict isKindOfClass:[NSMutableDictionary class]]) {
        self.accoutDict = [NSMutableDictionary dictionaryWithCapacity:0];
    }
}

+ (void)initialize
{
    if (sharedInstance == nil) {
        sharedInstance = [[self alloc] init];
    }
}

+ (id)sharedManager
{
    return sharedInstance ;
}

- (id)init
{
    if ((self = [super init])) {
        [self _loadAccountInfoFromFile];
    }
    return self;
}

@end
