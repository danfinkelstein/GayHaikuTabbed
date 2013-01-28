//
//  GHAppDefaults.h
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 1/10/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import <Foundation/Foundation.h>

extern int const tabBarHeight;
extern int const toolbarHeight;
extern int const shortToolbarHeight;
extern int const activityViewerDimension;
extern int const keyboardHeight;
extern int const buttonSideLength;
extern int const smallFontSize;
extern int const mediumFontSize;
extern int const largeFontSize;
extern int const gap;
extern int screenHeight;
extern int screenWidth;

@interface GHAppDefaults : NSObject

@property (nonatomic) BOOL checkboxUnchecked;               //Has user checked "don't use my haiku"?
@property (nonatomic) BOOL optOutSeen;                      //Has user ever been shown opt-out screen?
@property (nonatomic) BOOL instructionsSeen;                //Has user ever been shown the instructions?
@property (nonatomic) BOOL instructionsSwipedToFromOptOut;  //Has user ever swiped from settings screen to instructions screen?
@property (nonatomic) BOOL largeText;
@property (nonatomic) BOOL disableSyllableCheck;
@property (nonatomic) BOOL permissionDenied;
@property (nonatomic, strong) NSString *author;             //Author name the user has entered.
@property (nonatomic, strong) NSUserDefaults *defaults;     //Instantiation of user defaults.
@property (nonatomic, strong) UIColor *screenColorTrans;
@property (nonatomic, strong) UIColor *screenColorOp;

+ (GHAppDefaults *)sharedInstance;
-(void)setUserDefaults;

@end
