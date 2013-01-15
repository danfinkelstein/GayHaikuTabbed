//
//  GHAppDefaults.m
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 1/10/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import "GHAppDefaults.h"

float const screenWidthPhone = 320;
float const screenWidthPad = 1024;
float const screenHeightPad = 768;
float const tabBarHeight = 49;
float const toolbarHeight = 44;
float const keyboardHeight = 216;
float const buttonSideLength = 44;
float const smallFontSize = 12;
float const largeFontSize = 14;
float const gap = 10;

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


@end
