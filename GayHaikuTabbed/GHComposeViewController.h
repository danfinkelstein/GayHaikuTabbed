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
#import "GHUserSettings.h"

@interface GHComposeViewController : UIViewController <UITextViewDelegate,UIAlertViewDelegate,UITextFieldDelegate> {
    BOOL bypassSyllableCheck;
    BOOL instructionsSeen;
    BOOL animateComposeScreen;
    UITextView *instructions;
    UITextView *textView;
    UITextView *nextInstructions;
    UIAlertView *alert;
    GHHaiku *ghhaiku;
    GHVerify *ghverify;
    GHUserSettings *userSettings;
    UIImageView *background;
}

@end