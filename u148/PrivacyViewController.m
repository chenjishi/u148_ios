//
//  PrivacyViewController.m
//  u148
//
//  Created by 陈吉诗 on 14-9-11.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "PrivacyViewController.h"

@interface PrivacyViewController ()
{
    UIWebView *webView;
}

@end

@implementation PrivacyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:246.0f/255 green:246.0f/255 blue:246.0f/255 alpha:1.0f];
    
    webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:webView];
    
    [self renderPage];
}

- (void)renderPage
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"usite" ofType:@"html" inDirectory:@"html"]];
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"usite" ofType:@"html" inDirectory:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{TITLE}" withString:@"注册条款"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{U_AUTHOR}" withString:@""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{U_COMMENT}" withString:@""];
    
    NSString *content = @"<div>为维护网上公共秩序和社会稳定，请您自觉遵守以下条款:<br/><br/>一、不得利用本站危害国家安全、泄露国家秘密，不得侵犯国家社会集体的和公民的合法权益，不得利用本站制作、复制和传播下列信息：<br/>（一）煽动抗拒、破坏宪法和法律、行政法规实施的； <br/>（二）煽动颠覆国家政权，推翻社会主义制度的；<br/>（三）煽动分裂国家、破坏国家统一的；<br/>（四）煽动民族仇恨、民族歧视，破坏民族团结的；<br/>（五）捏造或者歪曲事实，散布谣言，扰乱社会秩序的；<br/>（六）宣扬封建迷信、淫秽、色情、赌博、暴力、凶杀、恐怖、教唆犯罪的； <br/>（七）公然侮辱他人或者捏造事实诽谤他人的，或者进行其他恶意攻击的；<br/>（八）损害国家机关信誉的； <br/>（九）其他违反宪法和法律行政法规的； <br/></div>（十）进行商业广告行为的。 <br/><br/>二、互相尊重，对自己的言论和行为负责。 <br/><br/><div align=\"center\"><a href=\"http://www.u148.net/user/agreement.html\">协议条款</a></div></div>";
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{CONTENT}" withString:content];
    
    [webView loadHTMLString:htmlString baseURL:url];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
