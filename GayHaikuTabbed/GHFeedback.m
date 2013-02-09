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
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
                //Creates a UIImageView in which and a CGRect with which to display the background image.  

    CGRect frame;
    screenHeight = self.view.bounds.size.height;
    screenWidth = self.view.bounds.size.width;
    frame = CGRectMake(0, 0, screenWidth, (screenHeight-TAB_BAR_HEIGHT));
    UIImageView *bground = [[UIImageView alloc] initWithFrame:frame];
    if (screenHeight<500) {
        bground.image = [UIImage imageNamed:@"main.png"];
    }
    else {
        bground.image = [UIImage imageNamed:@"5main.png"];
    }
    [self.view addSubview:bground];
    [self displayFeedbackText];
}

-(void)displayFeedbackText {
    UITextView *feedback = [[UITextView alloc] init];
    feedback.backgroundColor = [UIColor clearColor];
    feedback.font = [UIFont fontWithName:@"Georgia" size:MEDIUM_FONT_SIZE];
    NSString *t = @"If you have any problems with the ap";
    int textWidth = [t sizeWithFont:[UIFont fontWithName:@"Georgia" size:MEDIUM_FONT_SIZE]].width;
    int textHeight = [t sizeWithFont:[UIFont fontWithName:@"Georgia" size:MEDIUM_FONT_SIZE]].height;
    feedback.text = @"Thank you for buying Gay Haiku! \nIf you have any problems with the \napp, or if you want to share any \nthoughts or suggestions, please \nemail me at joel@joelderfner.com.";
    feedback.editable = NO;
    feedback.dataDetectorTypes = UIDataDetectorTypeAll;
    feedback.translatesAutoresizingMaskIntoConstraints = NO;
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

@end
