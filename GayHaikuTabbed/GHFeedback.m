//
//  GHFeedback.m
//  Gay Haiku
//
//  Created by Joel Derfner on 12/2/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import "GHFeedback.h"
#import "GHAppDefaults.h"
#import "GHHaiku.h"

@interface GHFeedback ()

@end

@implementation GHFeedback

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Creates a UIImageView in which and a CGRect with which to display the background image.
    
    screenHeight = self.view.bounds.size.height;
    screenWidth = self.view.bounds.size.width;
    CGRect frame = CGRectMake(0, 0, screenWidth, (screenHeight-TAB_BAR_HEIGHT));
    UIImageView *background = [[UIImageView alloc] initWithFrame:frame];
    background.image = screenHeight<500 ? [UIImage imageNamed:@"main.png"]:[UIImage imageNamed:@"5main.png"];
    [self.view addSubview:background];
    [self displayFeedbackText];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)displayFeedbackText {
    
    UITextView *feedback;
    
    if (NSFoundationVersionNumber>NSFoundationVersionNumber_iOS_6_1) {
        //iOS7 code
        feedback = [[UITextView alloc] initWithFrame:CGRectMake(40, 200, 280, 200)];
    }
    else {
        feedback = [[UITextView alloc] init];
    }
    
    //This is what the code SHOULD be, and will be once I figure out how to deal with constraints in iOS7:
    
    feedback.backgroundColor = [UIColor clearColor];
    feedback.font = [UIFont fontWithName:@"Georgia" size:MEDIUM_FONT_SIZE];
    feedback.text = @"Thank you for buying Gay Haiku! \nIf you have any problems with the \napp, or if you want to share any \nthoughts or suggestions, please \nemail me at joel@joelderfner.com.";
    feedback.editable = NO;
    feedback.dataDetectorTypes = UIDataDetectorTypeAll;
    feedback.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (NSFoundationVersionNumber<=NSFoundationVersionNumber_iOS_6_1) {
        
        //This is a hack designed to deal with the margin padding that comes with UITextView.
        
        NSString *t = @"If you have any problems with the ap";
        int textWidth = [t sizeWithFont:[UIFont fontWithName:@"Georgia" size:MEDIUM_FONT_SIZE]].width;
        int textHeight = [t sizeWithFont:[UIFont fontWithName:@"Georgia" size:MEDIUM_FONT_SIZE]].height;
        
        //Set layout constraints.
        
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:feedback attribute:NSLayoutAttributeWidth relatedBy:0 toItem:nil attribute:NSLayoutAttributeWidth multiplier:1  constant:textWidth];
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:feedback attribute:NSLayoutAttributeHeight relatedBy:0 toItem:nil attribute:NSLayoutAttributeHeight multiplier:1  constant:textHeight*6];
        NSLayoutConstraint *constraintX = [NSLayoutConstraint constraintWithItem:feedback attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *constraintY = [NSLayoutConstraint constraintWithItem:feedback attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [self.view addConstraint:constraintX];
        [self.view addConstraint:constraintY];
        [self.view addConstraint:widthConstraint];
        [self.view addConstraint:heightConstraint];
        
    }
    
    [self.view addSubview:feedback];
}

@end
