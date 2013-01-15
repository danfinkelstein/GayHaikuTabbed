//
//  GHFeedback.m
//  Gay Haiku
//
//  Created by Joel Derfner on 12/2/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import "GHFeedback.h"
#import "GHAppDefaults.h"

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
    
            //Creates a UIImageView in which and a CGRect with which to display the background image.  
    
    CGRect frame;
    float screenHeight = self.view.bounds.size.height;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        NSLog(@"is Phone");
        frame = CGRectMake(0, 0, screenWidthPhone, (screenHeight-tabBarHeight));
        background = [[UIImageView alloc] initWithFrame:frame];
        if (screenHeight<500) {
            background.image=[UIImage imageNamed:@"temp background.jpg"];
        }
        else {
            background.image=[UIImage imageNamed:@"iPhone5 temp background.jpg"];
        }
    }
    else {
        NSLog(@"Is iPad.");
        if (self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
            frame = CGRectMake(0, 0, screenWidthPad, (screenHeightPad-tabBarHeight));
        }
        else {
            frame = CGRectMake(0, 0, screenHeightPad, (screenWidthPad-tabBarHeight));
        }
        background = [[UIImageView alloc] initWithFrame:frame];
        if (self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
            background.image=[UIImage imageNamed:@"iPad portrait GHViewController.jpg"];
        }
        else {
            background.image=[UIImage imageNamed:@"iPad landscape GHViewController.jpg"];
        }
    }
    [self.view addSubview:background];
    [self displaySettingsText];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if((self.interfaceOrientation == UIDeviceOrientationLandscapeLeft) || (self.interfaceOrientation == UIDeviceOrientationLandscapeRight)){
        background.image = [UIImage imageNamed:@"image-landscape.png"];
    } else  if((self.interfaceOrientation == UIDeviceOrientationPortrait) || (self.interfaceOrientation == UIDeviceOrientationPortraitUpsideDown)){
        background.image = [UIImage imageNamed:@"image-portrait.png"];
    }
}

-(void)displaySettingsText {
    if (!feedback) {
        feedback = [[UITextView alloc] init];
        feedback.backgroundColor = [UIColor clearColor];
        feedback.font = [UIFont fontWithName:@"Helvetica Neue" size:largeFontSize];
        feedback.text=@"Thank you for buying Gay Haiku! \nIf you have any problems with the \napp, or if you want to share any \nthoughts or suggestions, please \nemail me at joel@joelderfner.com.";
        feedback.editable=NO;
        NSString *t = @"If you have any problems with the    ";
        float textWidth = [t sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:largeFontSize]].width;
        float textHeight = [t sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:largeFontSize]].height;
        feedback.frame = CGRectMake(self.view.bounds.size.width/2-textWidth/2, (self.view.bounds.size.height/2-tabBarHeight) - (textHeight*6)/2, textWidth, textHeight*6);
        feedback.dataDetectorTypes=UIDataDetectorTypeAll;
        [self.view addSubview:feedback];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
