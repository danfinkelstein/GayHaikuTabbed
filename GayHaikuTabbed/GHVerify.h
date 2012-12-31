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
    tooManyLines=2,
    tooFewLines=0,
    rightNumberOfLines=1,
    blah
} numberOfLines;

@interface GHVerify : NSObject

@property (nonatomic, strong) NSArray *listOfLines;
@property (nonatomic, strong) NSMutableArray *linesAfterCheck;
@property (nonatomic, strong) GHHaiku *ghhaiku;
@property (nonatomic) numberOfLines numberOfLinesAsProperty;

-(int)syllablesInLine: (NSString *)line;
-(NSArray *)splitHaikuIntoLines: (NSString *)haiku;
-(BOOL)checkHaikuSyllables;

@end
