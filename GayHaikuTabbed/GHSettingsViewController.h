//
//  GHSettingsViewController.h
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 1/6/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHAppDefaults.h"
#import <QuartzCore/QuartzCore.h>


@interface GHSettingsViewController : UIViewController <UITextFieldDelegate> {
    IBOutlet UITextField *nameField;             //Field for user to enter name.
    //UIButton *checkboxButton;           //Button for user to opt out of my including haiku in future versions of app.
    //UITextView *infoAbout;
    //UITextView *settingsPartOne;          //Text asking for name.
    //UITextView *settingsPartTwo;          //Test asking for opt-out.
    UITextView *swipeInstructions;        //Instructions to swipe to get to GHComposeViewController.
    GHAppDefaults *userSettings;            //Instantiation of GHUserSettings.
    int screenHeight;
    int screenWidth;
    //CGRect thisRect;
    //UIImageView *nameFieldImage;
    UIImageView *background;
    //UISegmentedControl *aboutButton;
    //UISegmentedControl *backButton;
    UIColor *screenColor;
    IBOutlet UISegmentedControl *permissionDenied;
    IBOutlet UISegmentedControl *disableVerification;
}

-(IBAction)givePermission:(UISegmentedControl *)sender;
-(IBAction)disableSyllableVerification:(UISegmentedControl *)sender;

@end
