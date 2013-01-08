//
//  GHSettingsViewController.h
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 1/6/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHUserSettings.h"

@interface GHSettingsViewController : UIViewController <UITextFieldDelegate> {
    UITextField *nameField;
    UIButton *checkboxButton;
    UITextView *settingsPartOne;
    UITextView *settingsPartTwo;
    UITextView *swipeInstructions;
    UIImageView *background;
    GHUserSettings *userSettings;
    BOOL checkboxChecked;
}

@end
