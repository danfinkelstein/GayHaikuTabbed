//
//  GHSettingsViewController.h
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 1/6/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHAppDefaults.h"


@interface GHSettingsViewController : UIViewController <UITextFieldDelegate> {
    UITextField *nameField;             //Field for user to enter name.
    UIButton *checkboxButton;           //Button for user to opt out of my including haiku in future versions of app.
    UITextView *settingsPartOne;        //Text asking for name.
    UITextView *settingsPartTwo;        //Test asking for opt-out.
    UITextView *swipeInstructions;      //Instructions to swipe to get to GHComposeViewController.
    GHAppDefaults *userSettings;       //Instantiation of GHUserSettings.
}

@end
