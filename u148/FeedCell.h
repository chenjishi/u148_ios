//
//  FeedCell.h
//  u148
//
//  Created by 陈吉诗 on 14-7-19.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FLAnimatedImageView;

@interface FeedCell : UITableViewCell

@property (nonatomic, strong) UILabel *reviewsLabel;
@property (nonatomic, strong) FLAnimatedImageView *postImage;
@property (nonatomic, strong) UIView *separatorView;

@end
