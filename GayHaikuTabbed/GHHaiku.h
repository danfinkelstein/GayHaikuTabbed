//
//  GHHaiku.h
//  Gay Haiku
//
//  Created by Joel Derfner on 9/15/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GHHaiku : NSObject

+(GHHaiku *)sharedInstance;

-(int)chooseNumber:(int)blah;
-(void)haikuToShow;

@property (nonatomic) int newIndex;                             //Index of the current haiku.
@property (nonatomic) BOOL justComposed;                        //Alerts home screen to display properly upon return from compose screen.
@property (nonatomic) BOOL isUserHaiku;                         //Indicates that haiku was written by the user.
@property (nonatomic) BOOL userIsEditing;                       //Alerts compose screen that user is editing (rather than composing afresh).
@property (nonatomic, strong) NSMutableArray *gayHaiku;         //Array of all haiku.
@property (nonatomic, strong) NSString *text;                   //Text of haiku.
@property (nonatomic, strong) NSMutableArray *haikuLoaded;      //Array of haiku loaded from plist.

-(void) loadHaiku;                                              //Loads haiku from plist.
-(void) saveToDocsFolder:(NSString *)string;                    //Saves haiku array to plist.

@end
