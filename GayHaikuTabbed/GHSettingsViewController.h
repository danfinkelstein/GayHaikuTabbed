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
    UITextView *swipeInstructions;        //Instructions to swipe to get to GHComposeViewController.
    GHAppDefaults *userSettings;            //Instantiation of GHUserSettings.
    int screenHeight;
    int screenWidth;
    UIImageView *background;
    UIColor *screenColor;
    IBOutlet UISegmentedControl *permissionDenied;
    IBOutlet UISegmentedControl *disableVerification;
}

-(IBAction)givePermission:(UISegmentedControl *)sender;
-(IBAction)disableSyllableVerification:(UISegmentedControl *)sender;

@end
