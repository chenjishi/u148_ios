//
//  SurprizeViewController.h
//  u148
//
//  Created by 陈吉诗 on 14-8-3.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "CustomIOS7AlertView.h"

@interface SurprizeViewController : UIViewController
{
    UIImageView *dolphin;
    UIImageView *bubbleBreakView;
    
    UIView *containerView;
    
    UILabel *shakeLabel;
    
    AVAudioPlayer *waterPlayer;
    
    UIImage *bubbleImage;
    
    UIImageView *mImageView;
    UILabel *mUILabel;
    
    UIButton *exitButton;
    
    BOOL blowed;
    
    CustomIOS7AlertView *popwindow;
    
    NSMutableArray *dataArray;
    
    int currentIndex;
}

@property (assign) SystemSoundID pewPewSound;

@end
