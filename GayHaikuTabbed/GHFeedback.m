//
//  GHFeedback.m
//  Gay Haiku
//
//  Created by Joel Derfner on 12/2/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import "GHFeedback.h"

@interface GHFeedback ()

@end

@implementation GHFeedback

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
    
    // Create a UIImageView in which and a CGRect with which to display the background image.
    
    UIImageView *background;
    CGRect frame;
    
    //Determine whether you're using a 3.5-inch screen or a 4-inch screen.
    
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    //If you're using a 3.5-inch screen, use the shorter background image.
    
    if (screenHeight<500) {
        frame = CGRectMake(0, 0, 320, (480-49));
    }
    
    //If you're using a 4-inch screen, use the taller background image.
    
    else {
        frame = CGRectMake(0, 0, 320, (568-49));
    }
    background = [[UIImageView alloc] initWithFrame:frame];
    
    //Load the image.
    
    if (screenHeight<500) {
        background.image=[UIImage imageNamed:@"temp background.jpg"];
    }
    else {
        background.image=[UIImage imageNamed:@"iPhone5 temp background.jpg"];
    }
    [self.view addSubview:background];
    [self.view bringSubviewToFront:feedback];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
