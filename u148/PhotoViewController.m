//
//  PhotoViewController.m
//  u148
//
//  Created by 陈吉诗 on 14-7-23.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "PhotoViewController.h"
#import "AFHTTPRequestOperation.h"

@interface PhotoViewController ()

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
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:imageView];
    
    [self requestImage];
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
