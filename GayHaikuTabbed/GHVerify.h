//
//  GHVerify.h
//  Gay Haiku
//
//  Created by Joel Derfner on 12/1/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+RNTextStatistics.h"
#import "GHHaiku.h"

typedef enum {
    tooFewLines,
    rightNumberOfLines,
    tooManyLines
} numberOfLines;

@interface GHVerify : NSObject

@property (nonatomic, strong) NSArray *listOfLines;             //An array of lines in the haiku.
@property (nonatomic, strong) NSMutableArray *linesAfterCheck;  //An array to hold the syllable verification of each line.
@property (nonatomic, strong) GHHaiku *ghhaiku;                 //An instantiation of GHHaiku.
@property (nonatomic) numberOfLines numberOfLinesAsProperty;    //The number of lines in the haiku.

-(NSArray *)splitHaikuIntoWords: (NSString *)haiku;
-(NSArray *)splitHaikuIntoLines: (NSString *)haiku;             //Splits the haiku into lines.
-(int)syllablesInLine: (NSString *)line;                        //Counts the syllables in the given line.
-(BOOL)checkHaikuSyllables;                                     //Checks whether lines have correct number of syllables.

@end
