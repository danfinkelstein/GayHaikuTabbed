//
//  GHHaikuViewController.h
//  Gay Haiku
//
//  Created by Joel Derfner on 12/2/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHHaiku.h"

@interface GHHaikuViewController : UIViewController <UITextViewDelegate,UIGestureRecognizerDelegate> {
    BOOL swipePreviousInstructionsSeen;
    BOOL swipeNextInstructionsSeen;
    UITextView *previousInstructions;
    UITextView *nextInstructions;
    UIAlertView *alert;
    NSString *serviceType;
    UINavigationItem *titleBar;
    UINavigationBar *navBar;
    BOOL comingFromPrevious;
}

@property (nonatomic, strong) GHHaiku *ghhaiku;

@property (nonatomic, strong) IBOutlet UITextView *displayHaikuTextView;

-(IBAction)goToNextHaiku;
-(IBAction)goToPreviousHaiku;

@end