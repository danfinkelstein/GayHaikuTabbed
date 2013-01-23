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
#import "GHAppDefaults.h"

@interface GHComposeViewController : UIViewController <UITextViewDelegate,UIAlertViewDelegate,UITextFieldDelegate> {
    UIImageView *background;            //Image to use as background.
    BOOL bypassSyllableCheck;           //Whether to bypass the syllable-check verification function.
    BOOL animateComposeScreen;          //If we're coming from the instructions screen, animate the compose screen appearance.
    BOOL syllablesWrong;
    UITextView *instructions;           //Text of the instructions.
    UITextView *textView;               //Editable text view for haiku entry.
    UITextView *nextInstructions;       //Contains the instructions for moving from instructions to compose (should be a label?)
    UIAlertView *alert;                 //Alert in case of syllable errors.
    int screenHeight;
    int screenWidth;
    CGRect frame;
    UIColor *screenColor;
    NSString *haikuWithAttribution;
    GHHaiku *ghhaiku;                   //Instantiation of GHHaiku.
    GHVerify *ghverify;                 //Instantiation of GHVerify.
    GHAppDefaults *userSettings;       //Instantiation of GHUserSettings.
}

@end