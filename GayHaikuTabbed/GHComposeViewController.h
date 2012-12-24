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
}

//@property (nonatomic) BOOL instructionsSeen;
//@property (nonatomic) BOOL optOutSeen;
//@property (nonatomic, strong) UITextView *instructions;
//@property (nonatomic, strong) UITextView *textView;
//@property (nonatomic, strong) UITextView *optOut;
//@property (nonatomic) BOOL checkboxChecked;
//@property (nonatomic, strong) UIAlertView *alert;
//@property (nonatomic, strong) GHHaiku *ghhaiku;
//@property (nonatomic, strong) GHVerify *ghverify;
//@property (nonatomic) int screen;
//@property (nonatomic, strong) UITextView *nextInstructions;
//@property (nonatomic, strong) UITextView *previousInstructions;
//@property (nonatomic) BOOL instructionsHaveBeenSeenThisSession;
//@property (nonatomic) BOOL optOutHasBeenSeenThisSession;
//@property (nonatomic) BOOL bypassSyllableCheck;

@property (nonatomic, weak) IBOutlet UIImageView *screenBackground;
@property (nonatomic, weak) IBOutlet UIButton *checkboxButton;
@property (nonatomic, weak) IBOutlet UITextField *nameField;

-(IBAction)checkCheckbox;

@end