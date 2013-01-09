//
//  GHUserSettings.m
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 1/6/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import "GHUserSettings.h"

@implementation GHUserSettings

@synthesize checkboxChecked, optOutSeen, instructionsSeen, instructionsSwipedToFromOptOut, author, defaults;

            

+ (GHUserSettings *)sharedInstance {
    
                //Make GHUserSettings a singleton class.
    
    static GHUserSettings *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GHUserSettings alloc] init];
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
     */
}

@end
