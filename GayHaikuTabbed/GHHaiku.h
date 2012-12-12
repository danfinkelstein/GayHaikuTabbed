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

-(int)chooseNumber;
-(NSString *)haikuToShow;

@property (nonatomic) int index;
@property (nonatomic, strong) NSMutableArray *gayHaiku;
@property (nonatomic, strong) NSMutableArray *arrayOfSeen;
@property (nonatomic, strong) NSMutableArray *mutArr;
@property (nonatomic, strong) NSMutableArray *mutArrUser;
@property (nonatomic, strong) NSArray *arrayAfterFiltering;
@property (nonatomic, strong) NSString *selectedCategory;
@property (nonatomic) BOOL justComposed;
@property (nonatomic) BOOL isUserHaiku;

-(void) loadHaiku;
-(void) saveToDocsFolder:(NSString *)string;

@end
