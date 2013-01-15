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
    
    UIImageView *background;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGRect frame = CGRectMake(0, 0, screenWidth, screenHeight-tabBarHeight);
    background = [[UIImageView alloc] initWithFrame:frame];
    
            //Determine whether you're using a 3.5-inch screen or a 4-inch screen.  If you're using a 3.5-inch screen, use the shorter background image.
    
    if (screenHeight<500) {
        background.image=[UIImage imageNamed:@"temp background.jpg"];
    }
    else {
        background.image=[UIImage imageNamed:@"iPhone5 temp background.jpg"];
    }
    [self.view addSubview:background];
    [self displaySettingsText];
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
        feedback.frame = CGRectMake(screenWidth/2-textWidth/2, ([[UIScreen mainScreen] bounds].size.height/2-tabBarHeight) - (textHeight*6)/2, textWidth, textHeight*6);
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
