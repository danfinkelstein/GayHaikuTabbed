//
//  GHHaikuViewController.h
//  Gay Haiku
//
//  Created by Joel Derfner on 12/2/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHHaiku.h"
#import "GHConstants.h"

@interface GHHaikuViewController : UIViewController <UITextViewDelegate,UIGestureRecognizerDelegate> {
    BOOL swipePreviousInstructionsSeen;         //Whether the user's seen "swipe" to get to previous screen
    BOOL swipeNextInstructionsSeen;             //Whether the user's seen "swipe" to get to next screen
    UITextView *previousInstructions;           //The actual textview with the swipe-for-previous instructions
    UITextView *nextInstructions;               //The actual textview with the swipe-for-next instructions
    UIAlertView *alert;                         //Alert for email/twitter/facebook errors
    NSString *serviceType;                      //Service type (email/twitter/facebook)
    UINavigationItem *titleBar;                 //Navigation item for temporary-view nav bar.
    UINavigationBar *navBar;                    //Temporary-view nav bar for sending/editing/deleting
    BOOL comingFromPrevious;                    //So we know which direction to animate haiku view from
    IBOutlet UITextView *displayHaikuTextView;  //Textview that displays the current haiku
    GHConstants *ghnumbers;
}

@property (nonatomic, strong) GHHaiku *ghhaiku;

-(IBAction)goToNextHaiku;                       //Method for moving to next haiku
-(IBAction)goToPreviousHaiku;                   //Method for moving to previous haiku

@end