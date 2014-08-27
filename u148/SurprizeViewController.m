//
//  SurprizeViewController.m
//  u148
//
//  Created by 陈吉诗 on 14-8-3.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "SurprizeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"
#import "AFHTTPRequestOperationManager.h"
#import "Bubble.h"

@import AVFoundation;

@interface SurprizeViewController ()

@end

@implementation SurprizeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //handle for iphone4 and iphone5
    UIImage *image;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (screenHeight > 480.0f) {
        image = [UIImage imageNamed:@"bubble_bkg5.jpg"];
    } else {
        image = [UIImage imageNamed:@"bubble_bkg4.jpg"];
    }
    
    dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    currentIndex = 0;
    
    bubbleImage = [UIImage imageNamed:@"ic_bubble.png"];
    
    UIImageView *bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    bgImage.image = image;
    [self.view addSubview:bgImage];
    
    NSMutableArray *dolphins = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 1; i < 10; i++) {
        [dolphins addObject:[UIImage imageNamed:[NSString stringWithFormat:@"dolphin%d.png", i]]];
    }
    
    NSMutableArray *bubbles = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 1; i < 4; i++) {
        [bubbles addObject:[UIImage imageNamed:[NSString stringWithFormat:@"bubble_break%d.png", i]]];
    }
    
    dolphin = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 120) / 2, 40, 100, 122)];
    dolphin.image = [UIImage imageNamed:@"dolphin_cry.png"];
    [dolphin setHidden:YES];
    [self.view addSubview:dolphin];
    
    UIImageView *animateView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, self.view.frame.size.height - 49.0f - 95.0f + 20.0f, 113.0f, 95.0f)];
    animateView.animationImages = dolphins;
    animateView.animationDuration = 2;
    animateView.animationRepeatCount = 0;
    [animateView startAnimating];
    [self.view addSubview:animateView];
    
    bubbleBreakView = [[UIImageView alloc] initWithFrame:CGRectZero];
    bubbleBreakView.animationImages = bubbles;
    bubbleBreakView.animationDuration = 1;
    bubbleBreakView.animationRepeatCount = 1;
    [self.view addSubview:bubbleBreakView];
    
    containerView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:containerView];
    
    shakeLabel = [[UILabel alloc] initWithFrame:CGRectMake(135.0f, self.view.frame.size.height - 49.0f - 50.0f, 0, 0)];
    shakeLabel.backgroundColor = [UIColor clearColor];
    shakeLabel.text = @"傻诗~";
    shakeLabel.textColor = [UIColor whiteColor];
    shakeLabel.font = [UIFont systemFontOfSize:16.0f];
    [shakeLabel sizeToFit];
    [self.view addSubview:shakeLabel];
    
    exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    exitButton.frame = CGRectMake(self.view.frame.size.width - 30 - 10, 40, 30, 30);
    
    [exitButton setImage:[UIImage imageNamed:@"icon_exit.png"] forState:UIControlStateNormal];
    [exitButton setImage:[UIImage imageNamed:@"icon_exit_press.png"] forState:UIControlStateHighlighted];
    [exitButton addTarget:self action:@selector(onExitClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exitButton];
    
    [self configureSystemSound];
    
    blowed = NO;
    
    [self request];
    
    [NSTimer scheduledTimerWithTimeInterval:(0.7) target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
}

- (void)request
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"http://u148.oss-cn-beijing.aliyuncs.com/image/bless"]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             if ([responseObject isKindOfClass:[NSArray class]]) {
                 NSArray *data = (NSArray *)responseObject;
                 
                 for (NSDictionary *dict in data) {
                     Bubble *bubble = [[Bubble alloc] initWidthDictionary:dict];
                     [dataArray addObject:bubble];
                 }
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"error %@", error);
         }];
}


- (void)onExitClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)playShakeLabel
{
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    shake.fromValue = [NSNumber numberWithFloat:-0.2];
    shake.toValue = [NSNumber numberWithFloat:+0.2];
    shake.duration = 0.2;
    shake.autoreverses = YES;
    shake.repeatCount = HUGE_VALF;
    [shakeLabel.layer addAnimation:shake forKey:@"blowText"];
    shakeLabel.alpha = 1.0f;
}

- (void) playWaterSoundOnBackground
{
    if (waterPlayer) {
        waterPlayer = nil;
    }
    
    NSURL *audioUrl = [[NSBundle mainBundle] URLForResource:@"water" withExtension:@"wav"];
    NSError *error;
    waterPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:&error];
    waterPlayer.numberOfLoops = -1;
    
    if (error == nil) {
        [waterPlayer prepareToPlay];
        [waterPlayer play];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (waterPlayer) {
        [waterPlayer stop];
    }
    [self stopFloatBubble];
}

- (void)playBreakAnimation:(CGRect)rect
{
    bubbleBreakView.frame = rect;
    [bubbleBreakView startAnimating];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startFloatBubble];
    [NSThread detachNewThreadSelector:@selector(playWaterSoundOnBackground) toTarget:self withObject:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self playShakeLabel];
}

- (void)onTimer
{
    if (!blowed) return;
    
    UIImageView* bubbleView = [[UIImageView alloc] initWithImage:bubbleImage];
    
    int startX = 24.0f;
	int endX = round(random() % 320);
    double scale = 1 / round(random() % 80) + 1.0;
	double speed = 1 / round(random() % 100) + 1.0;
	
	bubbleView.frame = CGRectMake(startX, self.view.frame.size.height - 40, 101.0 * scale, 101.0 * scale);
    
	[containerView addSubview:bubbleView];
    
    [UIView animateWithDuration:5 * speed
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         bubbleView.frame = CGRectMake(endX, -100.0, 101.0 * scale, 101.0 * scale);
                     }
                     completion:^(BOOL finished) {
                         [bubbleView removeFromSuperview];
                     }];
}

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [popwindow close];
    blowed = YES;
}

- (void)closePopupView
{
    [popwindow close];
    blowed = YES;
    exitButton.hidden = NO;
}

- (void)playBubbleSound
{
    AudioServicesPlaySystemSound(self.pewPewSound);
}

- (void)configureSystemSound
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bubble" ofType:@"wav"];
    NSURL *pewPewURL = [NSURL fileURLWithPath:path];
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)pewPewURL, &_pewPewSound);
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)showPopwindow
{
    if (!popwindow) {
        popwindow = [[CustomIOS7AlertView alloc] init];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 8, 216, 360)];
        
        CGRect rect = CGRectMake(8, 0, 200, 300);
        mImageView = [[UIImageView alloc] initWithFrame:rect];
        [view addSubview:mImageView];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(216 - 30, 0, 30, 30);
        
        [closeButton setImage:[UIImage imageNamed:@"icon_exit.png"] forState:UIControlStateNormal];
        [closeButton setImage:[UIImage imageNamed:@"icon_exit_press.png"] forState:UIControlStateHighlighted];
        [closeButton addTarget:self action:@selector(closePopupView) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:closeButton];
        
        mUILabel = [[UILabel alloc] initWithFrame:CGRectZero];
        mUILabel.font = [UIFont systemFontOfSize:12.f];
        mUILabel.backgroundColor = [UIColor clearColor];
        mUILabel.textColor = [UIColor colorWithRed:102.0f/255 green:102.0f/255 blue:102.0f/255 alpha:1.0f];
        [view addSubview:mUILabel];
        
        [popwindow setContainerView:view];
        [popwindow setUseMotionEffects:YES];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:4];
    
    if (dataArray.count > 0) {
        int count = dataArray.count;
        if (currentIndex == count) {
            currentIndex = 0;
        }
        
        Bubble *bubble = [dataArray objectAtIndex:currentIndex];
        
        [mImageView setImageWithURL:[NSURL URLWithString:bubble.image]
                   placeholderImage:nil];
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:bubble.title];
        [title addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [bubble.title length])];

        mUILabel.attributedText = title;
        
        currentIndex += 1;
    } else {
        NSString *tips = @"This Is For Yingna Chen, The Girl I Met Who Brights My Life";
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:tips];
        [title addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [tips length])];
        mUILabel.text = tips;
        mImageView.image = [UIImage imageNamed:@"yingna1.jpg"];
    }
    
    mUILabel.frame = CGRectMake(8, mImageView.frame.origin.y + mImageView.frame.size.height + 8, 216 - 16, 0);
    mUILabel.numberOfLines = 2;
    [mUILabel sizeToFit];
    
    exitButton.hidden = YES;
    
    [popwindow show];
}

- (void)startFloatBubble
{
    blowed = YES;
    //    [self performSelector:@selector(stopFloatBubble) withObject:nil afterDelay:5.0];
}

- (void)stopFloatBubble
{
    blowed = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLoaction = [touch locationInView:self.view];
    for (UIView *view in containerView.subviews) {
        if ([view.layer.presentationLayer hitTest:touchLoaction]) {
            //here you can get frame during the animaton
            CGRect rect = [[view.layer presentationLayer] frame];
            
            [view removeFromSuperview];
            [self playBreakAnimation:rect];
            [self playBubbleSound];
            
            [self showPopwindow];
            blowed = NO;
            
            [dolphin setHidden:YES];
            break;
        }
    }
}

- (void)onAnimationComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    UIImageView *flakeView = (__bridge UIImageView *)(context);
    
    if (flakeView) {
        [flakeView removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
