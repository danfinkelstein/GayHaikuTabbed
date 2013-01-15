//
//  GHAppDelegate.m
//  Gay Haiku
//
//  Created by Joel Derfner on 12/2/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import "GHAppDelegate.h"
#import "GHHaikuViewController.h"
#import "GHComposeViewController.h"
#import "GHWebViewController.h"
#import "GHSettingsViewController.h"
#import "GHFeedback.h"
#import <Parse/Parse.h>

@implementation GHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
        [self.window makeKeyAndVisible];

                //This sets the app to send user-generated haiku to the Parse database.  It's duplicated in GHHaikuViewController viewDidLoad, because at some point I installed it here and it wasn't working so I installed it there and it started working.  Almost certainly it's only necessary in one of those two places.  To do:  figure out which one.
    
    [Parse setApplicationId:@"M7vcXO7ccmhNUbnLhmfnnmV8ezLvvuMvHwNZXrs8"
                  clientKey:@"Aw8j7MhJwsHxW1FxoHKuXojNGvrPSjDkACs7egRi"];
    
                //This hides the status bar throughout the app.
    
    [UIApplication sharedApplication].statusBarHidden=YES;
    
//COMMENT THIS OUT FOR RELEASE:
    
    #define TESTING 1
    #ifdef TESTING
        [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    #endif
    
                //This connects beta testers to the app on testflightapp.com.
    
//TO CHANGE FOR RELEASE:  in Build Settings (top item in Project Navigator, choose Project rather than Targets), Deployment:  Strip Linked Product set to YES.  Strip Debug Symbols During Copy for Release set to YES.
    
    [TestFlight takeOff:@"91f34663f587b0ef83a11eb009268b4f_MTQ1OTk5MjAxMi0xMC0yMiAwODozNzowNC42MzY4NzM"];
    
    NSMutableArray *tabItems = [[NSMutableArray alloc] initWithCapacity:2];
    
    GHHaikuViewController *hvc = [[GHHaikuViewController alloc] init];
    hvc.tabBarItem.title = @"Home";
    hvc.tabBarItem.image = [UIImage imageNamed:@"53-house.png"];
    [tabItems addObject:hvc];
    
    GHComposeViewController *cvc = [[GHComposeViewController alloc] init];
    cvc.tabBarItem.title = @"Compose";
    cvc.tabBarItem.image = [UIImage imageNamed:@"216-compose.png"];
    [tabItems addObject:cvc];
    
    GHWebViewController *wvc = [[GHWebViewController alloc] init];
    wvc.tabBarItem.title = @"Buy";
    wvc.tabBarItem.image = [UIImage imageNamed:@"80-shopping-cart.png"];
    [tabItems addObject:wvc];
    
    GHFeedback *fvc = [[GHFeedback alloc] init];
    fvc.tabBarItem.title = @"Feedback";
    fvc.tabBarItem.image = [UIImage imageNamed:@"18-envelope.png"];
    [tabItems addObject:fvc];
    
    GHSettingsViewController *svc = [[GHSettingsViewController alloc] init];
    svc.tabBarItem.title = @"Settings";
    svc.tabBarItem.image = [UIImage imageNamed:@"20-gear-2.png"];
    [tabItems addObject:svc];
    
    UITabBarController *tbc = [[UITabBarController alloc] init];
    tbc.viewControllers = tabItems;
    self.window.rootViewController = tbc;
    
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
