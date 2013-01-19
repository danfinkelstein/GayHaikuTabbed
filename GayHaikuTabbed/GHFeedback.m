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
    //self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.backgroundColor=[UIColor whiteColor];
    
            //Creates a UIImageView in which and a CGRect with which to display the background image.  

    CGRect frame;
    [self setWidthAndHeight];
    frame = CGRectMake(0, 0, screenWidth, (screenHeight-tabBarHeight));
    background = [[UIImageView alloc] initWithFrame:frame];
    background.backgroundColor = [UIColor whiteColor];
    if (screenHeight<500) {
        background.image=[UIImage imageNamed:@"main.png"];
    }
    else {
        background.image=[UIImage imageNamed:@"5main.png"];
    }
    [self.view addSubview:background];
    [self displayFeedbackText];
}

-(void)setWidthAndHeight {
    screenHeight = self.view.bounds.size.height;
    screenWidth = self.view.bounds.size.width;
}

-(void)displayFeedbackText {
    if (!feedback) {
        feedback = [[UITextView alloc] init];
        feedback.backgroundColor = [UIColor clearColor];
        feedback.font = [UIFont fontWithName:@"Helvetica Neue" size:mediumFontSize];
        NSString *t = @"If you have any problems with the ap";
        int textWidth = [t sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:mediumFontSize]].width;
        int textHeight = [t sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:mediumFontSize]].height;
        feedback.text=@"Thank you for buying Gay Haiku! \nIf you have any problems with the \napp, or if you want to share any \nthoughts or suggestions, please \nemail me at joel@joelderfner.com.";
        feedback.editable=NO;
        feedback.dataDetectorTypes=UIDataDetectorTypeAll;
        feedback.translatesAutoresizingMaskIntoConstraints=NO;
        NSLayoutConstraint *widthCon = [NSLayoutConstraint constraintWithItem:feedback attribute:NSLayoutAttributeWidth relatedBy:0 toItem:nil attribute:NSLayoutAttributeWidth multiplier:1  constant:textWidth];
        NSLayoutConstraint *heightCon = [NSLayoutConstraint constraintWithItem:feedback attribute:NSLayoutAttributeHeight relatedBy:0 toItem:nil attribute:NSLayoutAttributeHeight multiplier:1  constant:textHeight*6];
        NSLayoutConstraint *constraintX = [NSLayoutConstraint constraintWithItem:feedback attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *constraintY = [NSLayoutConstraint constraintWithItem:feedback attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [self.view addConstraint:constraintX];
        [self.view addConstraint:constraintY];
        [self.view addConstraint:widthCon];
        [self.view addConstraint:heightCon];
        [self.view addSubview:feedback];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
