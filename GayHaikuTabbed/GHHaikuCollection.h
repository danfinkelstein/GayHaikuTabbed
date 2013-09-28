//
//  GHHaikuCollection.h
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 3/17/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHHaikuInstance.h"

@interface GHHaikuCollection : NSObject

@property (nonatomic) BOOL favoritesListSelected;
@property (nonatomic) int newIndex;                             //Index of the current haiku.
@property (nonatomic) int newFavoritesIndex;
@property (nonatomic, strong) NSMutableArray *arrayOfGayHaiku;         //Array of all haiku.
@property (nonatomic, strong) NSMutableArray *arrayOfFavoriteHaiku;    //Text of haiku.
@property (nonatomic, strong) NSMutableArray *haikuLoaded;      //Array of haiku loaded from plist.

-(void) loadHaiku;                                              //Loads haiku from plist.
-(void) saveToDocsFolder:(NSString *)string;                    //Saves haiku array to plist.
+(GHHaikuCollection *)sharedInstance;

-(NSMutableArray *)createArrayOfFavoriteHaiku;
-(GHHaikuInstance *)haikuToShowFavorites;
-(GHHaikuInstance *)haikuToShowAll;


@end
