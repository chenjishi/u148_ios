//
//  SlideNavigationContorllerAnimationSlide.m
//  SlideMenu
//
//  Created by Aryan Gh on 1/26/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//
// https://github.com/aryaxt/iOS-Slide-Menu
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "SlideNavigationContorllerAnimatorSlide.h"

@implementation SlideNavigationContorllerAnimatorSlide

#pragma mark - Initialization -

- (id)init
{
    if (self = [self initWithSlideMovement:100])
    {
    }
    
    return self;
}

- (id)initWithSlideMovement:(CGFloat)slideMovement
{
	if (self = [super init])
	{
		self.slideMovement = slideMovement;
	}
	
	return self;
}

#pragma mark - SlideNavigationContorllerAnimation Methods -

- (void)prepareMenuForAnimation
{
    UIViewController *menuViewController = [SlideNavigationController sharedInstance].leftMenu;
	
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	CGRect rect = menuViewController.view.frame;
	
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        rect.origin.x = self.slideMovement*-1;
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            if (orientation == UIInterfaceOrientationLandscapeRight)
            {
                rect.origin.y = self.slideMovement*-1;
            }
            else
            {
                rect.origin.y = self.slideMovement*-1;
            }
        }
        else
        {
            if (orientation == UIInterfaceOrientationPortrait)
            {
                rect.origin.x = self.slideMovement*-1;
            }
            else
            {
                rect.origin.x = self.slideMovement*-1;
            }
        }
    }
    
    menuViewController.view.frame = rect;
}

- (void)animateMenuWithProgress:(CGFloat)progress
{
    UIViewController *menuViewController = [SlideNavigationController sharedInstance].leftMenu;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    NSInteger location = (self.slideMovement * -1) + (self.slideMovement * progress);
    location = (location > 0) ? 0 : location;
    
    CGRect rect = menuViewController.view.frame;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        rect.origin.x = location;
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            rect.origin.y = (orientation == UIInterfaceOrientationLandscapeRight) ? location : location*-1;
        }
        else
        {
            rect.origin.x = (orientation == UIInterfaceOrientationPortrait) ? location : location*-1;
        }
    }
    
    menuViewController.view.frame = rect;
}

- (void)clear
{
    [self clearMenu];
}

#pragma mark - Private Method -

- (void)clearMenu
{
    UIViewController *menuViewController = [SlideNavigationController sharedInstance].leftMenu;
    
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	
    CGRect rect = menuViewController.view.frame;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        rect.origin.x = 0;
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            rect.origin.y = 0;
        }
        else
        {
            rect.origin.x = 0;
        }
    }
    
    menuViewController.view.frame = rect;
}

@end
