//
//  GHAppDefaults.h
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 1/10/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import <Foundation/Foundation.h>

extern int const TAB_BAR_HEIGHT;
extern int const TOOLBAR_HEIGHT;
extern int const SHORT_TOOLBAR_HEIGHT;
extern int const ACTIVITY_VIEWER_DIMENSION;
extern int const SMALL_FONT_SIZE;
extern int const MEDIUM_FONT_SIZE;
extern int const LARGE_FONT_SIZE;
extern int screenHeight;
extern int screenWidth;

@interface GHAppDefaults : NSObject

@property (nonatomic) BOOL checkboxUnchecked;               //Has user checked "don't use my haiku"?
@property (nonatomic) BOOL optOutSeen;                      //Has user ever been shown opt-out screen?
@property (nonatomic) BOOL instructionsSeen;                //Has user ever been shown the instructions?
@property (nonatomic) BOOL instructionsSwipedToFromOptOut;  //Has user ever swiped from settings screen to instructions screen?
@property (nonatomic) BOOL fourThirteenSeen;
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
