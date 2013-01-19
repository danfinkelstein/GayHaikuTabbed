//
//  GHHaikuViewController.h
//  Gay Haiku
//
//  Created by Joel Derfner on 12/2/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHHaiku.h"
#import "GHAppDefaults.h"

@interface GHHaikuViewController : UIViewController <UITextViewDelegate,UIGestureRecognizerDelegate> {
    BOOL leftSwipeSeen;                         //Whether the user has seen "swipe" to get to previous screen
    BOOL rightSwipeSeen;                        //Whether the user has seen "swipe" to get to next screen
    UITextView *leftSwipe;                      //The actual textview with the swipe-for-previous instructions
    UITextView *rightSwipe;                     //The actual textview with the swipe-for-next instructions
    UIAlertView *alert;                         //Alert for email/twitter/facebook errors
    NSString *serviceType;                      //Service type (email/twitter/facebook)
    UINavigationItem *titleBar;                 //Navigation item for temporary-view nav bar.
    UINavigationBar *navBar;                    //Temporary-view nav bar for sending/editing/deleting
    BOOL comingFromPrevious;                    //So we know which direction to animate haiku view from
    UITextView *displayHaikuTextView;           //Textview that displays the current haiku
    GHAppDefaults *userSettings;
    UIImageView *background;
    int screenHeight;
    int screenWidth;
    NSLayoutConstraint *toolbarConstraintTop;
    NSLayoutConstraint *toolbarConstraintWidth;
    NSLayoutConstraint *toolbarConstraintHeight;
    IBOutlet UINavigationBar *navBarForPad;
}

@property (nonatomic, strong) GHHaiku *ghhaiku;

-(void)goToNextHaiku;                       //Method for moving to next haiku
-(void)goToPreviousHaiku;                   //Method for moving to previous haiku

@end