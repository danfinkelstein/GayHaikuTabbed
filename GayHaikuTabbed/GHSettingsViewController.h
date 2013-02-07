//
//  GHSettingsViewController.h
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 1/6/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface GHSettingsViewController : UIViewController <UITextFieldDelegate> {
    IBOutlet UITextField *nameField;             //Field for user to enter name.
    IBOutlet UISegmentedControl *permissionDenied;
    IBOutlet UISegmentedControl *disableVerification;
    IBOutlet UISegmentedControl *segCont;
}

-(IBAction)givePermission:(UISegmentedControl *)sender;
-(IBAction)disableSyllableVerification:(UISegmentedControl *)sender;
-(IBAction)displayInfo:(id)sender;

@end
