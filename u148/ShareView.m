//
//  ShareView.m
//  u148
//
//  Created by 陈吉诗 on 14-9-15.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "ShareView.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import "Feed.h"

#define MAX_ICON_COUNT 5
#define TAG_SHARE_SESSION 101
#define TAG_SHARE_FRIENDS 102
#define TAG_SHARE_WEIBO   103

@implementation ShareView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        titleArray = @[@"微信好友", @"朋友圈", @"新浪微博"];
        imageArray = @[@"ic_session.png", @"ic_friend.png", @"ic_wb.png"];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.69f];
        
        CGFloat iconWidth = (self.frame.size.width - 12 * 2 - (MAX_ICON_COUNT - 1) * 16) * 1.0f / MAX_ICON_COUNT;
        CGFloat iconHeight = iconWidth;
        
        CGFloat height = iconHeight + 2 * 12 + 12 + 6;
        
        UIButton *blankButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,
                                                                           self.frame.size.height - height)];
        [blankButton addTarget:self action:@selector(onDismiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:blankButton];
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - height,
                                                                         self.frame.size.width, height)];
        
        for (int i = 0; i < [imageArray count]; i++) {
            [containerView addSubview:[self getIconViewAtIndex:i withSize:iconWidth]];
        }
        
        containerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:containerView];
    }
    return self;
}

- (UIView *)getIconViewAtIndex:(int)index withSize:(CGFloat)size
{
    CGRect rect = CGRectMake(12 + 16 * index + size * index, 12, size, size + 6 + 12);
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.userInteractionEnabled = YES;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    button.tag = TAG_SHARE_SESSION + index;
    [button setImage:[UIImage imageNamed:[imageArray objectAtIndex:index]] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onShareClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, size + 6, size, 12.0f)];
    label.backgroundColor = [UIColor clearColor];
    label.text = [titleArray objectAtIndex:index];
    label.font = [UIFont systemFontOfSize:11.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:102.0f/255 green:102.0f/255 blue:102.0f/255 alpha:1.0f];
    [view addSubview:label];
    
    return view;
}

- (void)onShareClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger tag = button.tag;
    
    NSURL *url = [NSURL URLWithString:self.feedData.picMin];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    operation.responseSerializer = [AFImageResponseSerializer serializer];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if (responseObject) {
//            UIImage *image = (UIImage *)responseObject;
//            
//            if (tag == TAG_SHARE_FRIENDS || tag == TAG_SHARE_SESSION) {
//                [self sendToWeixin:image withType:tag];
//            } else {
//                [self sendToWeibo:image];
//            }
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//    }];
//    
//    [operation start];
}

- (void)sendToWeixin:(UIImage *) image withType:(NSInteger)scene
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = self.feedData.title;
    message.description = self.feedData.summary;
    [message setThumbImage:image];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = [NSString stringWithFormat:@"http://www.u148.net/article/%@.html", self.feedData.feedId];
    
    message.mediaObject = ext;
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene == TAG_SHARE_SESSION ? WXSceneSession : WXSceneTimeline;
    
    [WXApi sendReq:req];
    [self onDismiss];
}

- (void)sendToWeibo:(UIImage *)image
{
    WBMessageObject *message = [WBMessageObject message];
    
    WBWebpageObject *webObject = [WBWebpageObject object];
    webObject.objectID = [NSString stringWithFormat:@"u148_%@", self.feedData.feedId];
    webObject.title = self.feedData.title;
    webObject.description = self.feedData.summary;
    webObject.thumbnailData = UIImageJPEGRepresentation(image, 1.0f);
    webObject.webpageUrl = [NSString stringWithFormat:@"http://www.u148.net/article/%@.html", self.feedData.feedId];
    
    message.mediaObject = webObject;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    [WeiboSDK sendRequest:request];
    
    [self onDismiss];
}

- (void)onDismiss
{
    [self removeFromSuperview];
    if (_delegate) {
        [_delegate onShareViewDissmiss];
    }   
}
@end
