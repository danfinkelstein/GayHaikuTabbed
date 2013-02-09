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
}

- (NSUInteger)supportedInterfaceOrientations {
    if ( self.selectedIndex == 2 )
        return UIInterfaceOrientationMaskAll ;
    else
        return UIInterfaceOrientationMaskPortrait ;
}

@end
