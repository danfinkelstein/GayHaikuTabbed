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
    // Do any additional setup after loading the view from its nib.
    UIImageView *background;
    CGRect frame;
    
    if (!ghhaiku.iPhone5Screen) {
        frame = CGRectMake(0, 0, 320, (480-49));
        //CHANGE THIS ONCE I HAVE GRAPHICS
    }
    else {
        frame = CGRectMake(0, 0, 320, (568-49));
    }
    background = [[UIImageView alloc] initWithFrame:frame];
    if (!ghhaiku.iPhone5Screen) {
        //CHANGE THIS ONCE I HAVE GRAPHICS
        background.image=[UIImage imageNamed:@"temp background.jpg"];
    }
    else {
        background.image=[UIImage imageNamed:@"temp background.jpg"];
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
