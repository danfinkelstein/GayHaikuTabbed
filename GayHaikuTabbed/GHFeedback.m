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
    self.view.backgroundColor=[UIColor whiteColor];
    
            //Creates a UIImageView in which and a CGRect with which to display the background image.  
    
    CGRect frame;
    [self setWidthAndHeight];
    frame = CGRectMake(0, 0, screenWidth, (screenHeight-tabBarHeight));
    background = [[UIImageView alloc] initWithFrame:frame];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (screenHeight<500) {
            background.image=[UIImage imageNamed:@"temp background.jpg"];
        }
        else {
            background.image=[UIImage imageNamed:@"iPhone5 temp background.jpg"];
        }
    }
    else {
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

-(void)setWidthAndHeight {
    screenHeight = self.view.bounds.size.height;
    screenWidth = self.view.bounds.size.width;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self setWidthAndHeight];
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
        int fontSize;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            fontSize =24;
        }
        else {
            fontSize=14;
        }
        feedback.font = [UIFont fontWithName:@"Helvetica Neue" size:fontSize];
        NSString *t = @"If you have any problems with the ap";
        float textWidth = [t sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:fontSize]].width;
        float textHeight = [t sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:fontSize]].height;
        feedback.text=@"Thank you for buying Gay Haiku! \nIf you have any problems with the \napp, or if you want to share any \nthoughts or suggestions, please \nemail me at joel@joelderfner.com.";
        feedback.editable=NO;
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
