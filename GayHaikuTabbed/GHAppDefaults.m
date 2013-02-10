//
//  GHAppDefaults.m
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 1/10/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import "GHAppDefaults.h"

int const TAB_BAR_HEIGHT = 49;
int const TOOLBAR_HEIGHT = 44;
int const SHORT_TOOLBAR_HEIGHT = 32;
int const ACTIVITY_VIEWER_DIMENSION = 32;
int const SMALL_FONT_SIZE = 12;
int const MEDIUM_FONT_SIZE = 15;
int const LARGE_FONT_SIZE = 17;
int screenHeight;
int screenWidth;

@implementation GHAppDefaults

@synthesize checkboxUnchecked, optOutSeen, instructionsSeen, instructionsSwipedToFromOptOut, author, defaults, largeText, disableSyllableCheck, permissionDenied, screenColorOp, screenColorTrans;

+ (GHAppDefaults *)sharedInstance {
    
                //Make GHAppDefaults a singleton class.
    
    static GHAppDefaults *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GHAppDefaults alloc] init];
    });
    return sharedInstance;
}

-(void)setUserDefaults {
    
                //Set session settings to user defaults, if such exist.
    
    if (!self.defaults) self.defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"author"]) {
        self.author = ([defaults objectForKey:@"author"]) ? [defaults objectForKey:@"author"] : nil;
    }
    self.checkboxUnchecked = ([defaults boolForKey:@"checked?"]) ? [defaults boolForKey:@"checked?"] : YES;
    self.optOutSeen = ([defaults boolForKey:@"optOutSeen?"]) ? [defaults boolForKey:@"optOutSeen?"] : NO;
    self.instructionsSeen = ([defaults boolForKey:@"instructionsSeen?"]) ? [defaults boolForKey:@"instructionsSeen?"] : NO;
    self.instructionsSwipedToFromOptOut = ([defaults boolForKey:@"instructionsSwipedTo?"]) ? [defaults boolForKey:@"instructionsSwipedTo?"] : NO;
    self.permissionDenied = ([defaults boolForKey:@"permissionDenied?"]) ? [defaults boolForKey:@"permissionDenied?"]:NO;
    self.disableSyllableCheck = ([defaults boolForKey:@"disableSyllableCheck?"]) ? [defaults boolForKey:@"disableSyllableCheck?"] : NO;
    screenColorOp = [UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:1];
    screenColorTrans = [UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:.75];
    
                //UNCOMMENT THIS SECTION IF NECESSARY TO TEST
    
//    self.optOutSeen=NO;
//    self.instructionsSeen=NO;
//    self.instructionsSwipedToFromOptOut=NO;
//    self.author=nil;
    
}

@end
