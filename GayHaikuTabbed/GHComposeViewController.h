//
//  GHComposeViewController.h
//  Gay Haiku
//
//  Created by Joel Derfner on 12/2/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHVerify.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "GHHaiku.h"
#import "GHHaikuViewController.h"
#import "NSString+RNTextStatistics.h"

@interface GHComposeViewController : UIViewController <UITextViewDelegate,UIAlertViewDelegate,UITextFieldDelegate> {
    BOOL bypassSyllableCheck;
    BOOL optOutSeen;
    BOOL instructionsSeen;
    BOOL checkboxChecked;
    BOOL optOutHasBeenSeenThisSession;
    BOOL instructionsHaveBeenSeenThisSession;
    UITextView *instructions;
    UITextView *textView;
    UITextView *optOut;
    UITextView *nextInstructions;
    UITextView *previousInstructions;
    UIAlertView *alert;
    int screen;
    GHHaiku *ghhaiku;
    GHVerify *ghverify;
    UIImageView *background;
    IBOutlet UIButton *checkboxButton;
    IBOutlet UITextField *nameField;
}

-(IBAction)checkCheckbox;

@end