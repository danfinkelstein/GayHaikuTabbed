//
//  GHAppDefaults.m
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 1/10/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import "GHAppDefaults.h"

int const screenWidthPhone = 320;
int const screenWidthPad = 1024;
int const screenHeightPad = 768;
int const tabBarHeight = 49;
int const toolbarHeight = 44;
int const keyboardHeight = 216;
int const buttonSideLength = 44;
int const smallFontSize = 12;
int const mediumFontSize = 14;
int const largeFontSize = 17;
int const gap = 10;

@implementation GHAppDefaults

@synthesize checkboxChecked, optOutSeen, instructionsSeen, instructionsSwipedToFromOptOut, author, defaults;

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
    if ([defaults boolForKey:@"checked?"]) {
        self.checkboxChecked = [defaults boolForKey:@"checked?"];
    }
    else {
        self.checkboxChecked=NO;
    }
    if ([defaults objectForKey:@"author"]) {
        self.author = [defaults objectForKey:@"author"];
    }
    if ([defaults boolForKey:@"optOutSeen?"]) {
        self.optOutSeen = [defaults boolForKey:@"optOutSeen?"];
    }
    else {
        self.optOutSeen = NO;
    }
    if ([defaults boolForKey:@"instructionsSeen?"]) {
        self.instructionsSeen = [defaults boolForKey:@"instructionsSeen?"];
    }
    else {
        self.instructionsSeen = NO;
    }
    if ([defaults boolForKey:@"instructionsSwipedTo?"]) {
        self.instructionsSwipedToFromOptOut = [defaults boolForKey:@"instructionsSwipedTo?"];
    }
    else {
        self.instructionsSwipedToFromOptOut = NO;
    }
    
                //UNCOMMENT THIS SECTION IF NECESSARY TO TEST
    
    /*
    self.optOutSeen=NO;
    self.instructionsSeen=NO;
    self.instructionsSwipedToFromOptOut=NO;
    self.author=nil;
     */
    
}

-(BOOL)isPad {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
