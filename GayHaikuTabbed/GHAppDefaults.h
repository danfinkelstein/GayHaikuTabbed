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
extern float const smallFontSize;
extern float const largeFontSize;
extern float const gap;

@interface GHAppDefaults : NSObject

@property (nonatomic) BOOL checkboxChecked;                 //Has user checked "don't use my haiku"?
@property (nonatomic) BOOL optOutSeen;                      //Has user ever been shown opt-out screen?
@property (nonatomic) BOOL instructionsSeen;                //Has user ever been shown the instructions?
@property (nonatomic) BOOL instructionsSwipedToFromOptOut;  //Has user ever swiped from settings screen to instructions screen?
@property (nonatomic, strong) NSString *author;             //Author name the user has entered.
@property (nonatomic, strong) NSUserDefaults *defaults;     //Instantiation of user defaults.

+ (GHAppDefaults *)sharedInstance;
-(void)setUserDefaults;

@end
