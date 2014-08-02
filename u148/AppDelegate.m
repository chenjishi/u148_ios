//
//  AppDelegate.m
//  u148
//
//  Created by 陈吉诗 on 14-7-16.
//  Copyright (c) 2014年 u148. All rights reserved.
//

#import "AppDelegate.h"
#import "FeedsViewController.h"
#import "RootViewController.h"
#import "Flurry.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSArray *types = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:0],
                      [NSNumber numberWithUnsignedInteger:3],
                      [NSNumber numberWithUnsignedInteger:6],
                      [NSNumber numberWithUnsignedInteger:7],
                      [NSNumber numberWithUnsignedInteger:5],
                      [NSNumber numberWithUnsignedInteger:8],
                      [NSNumber numberWithUnsignedInteger:9],
                      nil];
    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithCapacity:6];
    for (NSUInteger i = 0; i < 6; i++) {
        FeedsViewController *viewController = [[FeedsViewController alloc] init];
        viewController.categoryType = [[types objectAtIndex:i] intValue];
        [viewControllers addObject:viewController];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    RootViewController *rootViewController = [[RootViewController alloc] initWithViewControllers:viewControllers];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    self.window.rootViewController = navController;
    
    self.window.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1];
    [self.window makeKeyAndVisible];
    
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"FGS28ZX973HSXN3P9WH8"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
