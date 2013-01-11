//
//  GHAppDefaults.h
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 1/10/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import <Foundation/Foundation.h>

extern float const screenWidth;
extern float const tabBarHeight;
extern float const toolbarHeight;
extern float const keyboardHeight;
extern float const buttonSideLength;

@interface GHAppDefaults : NSObject

@property (nonatomic) BOOL checkboxChecked;                 //Whether the user has checked "don't use my haiku" or not.
@property (nonatomic) BOOL optOutSeen;                      //Whether the user has ever been shown the opt-out screen or not.
@property (nonatomic) BOOL instructionsSeen;                //Whether the user has ever been shown the instructions.
@property (nonatomic) BOOL instructionsSwipedToFromOptOut;  //Whether the user has ever swiped from the settings screen to the instructions screen.
@property (nonatomic, strong) NSString *author;             //Author name the user has entered.
@property (nonatomic, strong) NSUserDefaults *defaults;

+ (GHAppDefaults *)sharedInstance;
-(void)setUserDefaults;

@end
