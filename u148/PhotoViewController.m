//
//  PhotoViewController.m
//  u148
//
//  Created by 陈吉诗 on 14-7-23.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "PhotoViewController.h"
#import "AFHTTPRequestOperation.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"

@interface PhotoViewController ()
{
    FLAnimatedImageView *imageView;
}

@end

@implementation PhotoViewController
@synthesize imageUrl = _imageUrl;



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"取消"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(onBackPressed)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(onSaveButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    UILabel *label = [[UILabel alloc] init];
    label.hidden = YES;
    label.text = @"GIF 图片加载中...";
    label.font = [UIFont systemFontOfSize:16.0];
    label.textColor = [UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1.0];
    label.frame = CGRectZero;
    [label sizeToFit];
    
    CGRect rect = label.frame;
    label.frame = CGRectMake((self.view.frame.size.width - rect.size.width) / 2,
                             (self.view.frame.size.height - rect.size.height) / 2,
                             rect.size.width,
                             rect.size.height);
    [self.view addSubview:label];
    
    imageView = [[FLAnimatedImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self.view addSubview:imageView];
    
    if ([_imageUrl hasSuffix:@".gif"]) {
        label.hidden = NO;
        [self requestGif];
    } else {
        [self requestImage];
    }
}

- (void)requestGif
{
    FLAnimatedImage * __block animatedImage = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:_imageUrl];
        NSData *data = [NSData dataWithContentsOfURL:url];
        animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
        
        CGSize size = animatedImage.size;
        
        CGFloat width = self.view.frame.size.width - 16;
        CGFloat height = width * size.height / size.width;
        
        imageView.frame = CGRectMake(8, (self.view.frame.size.height - height) / 2, width, height);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.animatedImage = animatedImage;
        });
    });
}

- (void)requestImage
{
    NSURL *url = [NSURL URLWithString:_imageUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            UIImage *image = (UIImage *)responseObject;
            
            CGFloat w = image.size.width;
            CGFloat h = image.size.height;
            
            CGFloat requestWidth = self.view.frame.size.width;
            CGFloat requestHeight = requestWidth * h / w;
            
            CGFloat y = (self.view.frame.size.height - 64.0f - requestHeight) / 2.0f;
            
            CGRect rect = CGRectMake(0, y, requestWidth, requestHeight);
            [self resizePicture:rect withImage:image];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
    [operation start];
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *) contextInfo
{
    NSString *message;
    NSString *title;
    if (!error) {
        title = @"成功提示";
        message = [NSString stringWithFormat:@"成功保存到相冊"];
    } else {
        title = @"失败提示";
        message = [error description];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"知道了"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)onSaveButtonPressed
{
    UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

- (void)onBackPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resizePicture:(CGRect)rect withImage:(UIImage *)image
{
    imageView.frame = rect;
    imageView.image = image;
}
@end
