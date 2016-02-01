//
//  ShareView.h
//  u148
//
//  Created by 陈吉诗 on 14-9-15.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Feed;

@protocol ShareDelegate <NSObject>

@required

- (void)onShareViewDissmiss;

@end

@interface ShareView : UIView
{
    NSArray *titleArray;
    NSArray *imageArray;
    UIImageView *imageView;
}

@property (nonatomic, strong) Feed *feedData;
@property (nonatomic, assign) id<ShareDelegate> delegate;

@end
