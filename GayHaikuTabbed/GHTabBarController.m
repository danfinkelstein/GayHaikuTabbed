//
//  GHTabBarController.m
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 1/22/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import "GHTabBarController.h"

@interface GHTabBarController ()

@end

@implementation GHTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (NSFoundationVersionNumber>NSFoundationVersionNumber_iOS_6_1) {
        //iOS7 code
        [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:1]];
        [[UITabBar appearance] setTintColor:[UIColor colorWithRed:227/255.0 green:180/255.0 blue:204/255.0 alpha:1]];
    }
    else {
        //iOS6 code
        [[UITabBar appearance] setTintColor:[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:1]];
        [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:227/255.0 green:180/255.0 blue:204/255.0 alpha:1]];
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    if ( self.selectedIndex == 2 )
        return UIInterfaceOrientationMaskAll ;
    else
        return UIInterfaceOrientationMaskPortrait ;
}

@end
