//
//  PhotoViewController.m
//  u148
//
//  Created by 陈吉诗 on 14-7-23.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "PhotoViewController.h"
#import "UIImageView+AFNetworking.h"

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
    
    [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_imageUrl]]
                     placeholderImage:[UIImage imageNamed:@"ic_place_holder.png"]
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  CGFloat w = image.size.width;
                                  CGFloat h = image.size.height;
                                  
                                  CGFloat requestWidth = 320.f;
                                  CGFloat requestHeight = requestWidth * h / w;
                                  
                                  CGFloat y = (self.view.frame.size.height - 64.0f - requestHeight) / 2.0f;
                                  
                                  CGRect rect = CGRectMake(0, y, requestWidth, requestHeight);
                                  [self resizePicture:rect withImage:image];
                              }
                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                  
                              }];
    
    [self.view addSubview:imageView];
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
    NSLog(@"onBackPressed");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resizePicture:(CGRect)rect withImage:(UIImage *)image
{
    imageView.frame = rect;
    imageView.image = image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
