//
//  GHUserSettings
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 1/6/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHUserSettings : NSObject

@property (nonatomic) BOOL checkboxChecked;
@property (nonatomic) BOOL optOutSeen;
@property (nonatomic) BOOL instructionsSeen;
@property (nonatomic) BOOL instructionsSwipedToFromOptOut;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSUserDefaults *defaults;

+ (GHUserSettings *)sharedInstance;
-(void)setUserDefaults;

@end
