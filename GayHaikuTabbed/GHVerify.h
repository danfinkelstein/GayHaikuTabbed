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

@interface GHVerify : NSObject

@property (nonatomic, strong) NSArray *listOfLines;
@property (nonatomic, strong) NSMutableArray *linesAfterCheck;
@property (nonatomic, strong) GHHaiku *ghhaiku;
@property (nonatomic, strong) NSString *correctNumberOfLines;
@property (nonatomic, strong) NSString *correctNumberOfSyllablesInFirstLine;
@property (nonatomic, strong) NSString *correctNumberOfSyllablesInSecondLine;
@property (nonatomic, strong) NSString *correctNumberOfSyllablesInThirdLine;

-(int)syllablesInLine: (NSString *)line;
-(NSArray *)splitHaikuIntoLines: (NSString *)haiku;
-(BOOL)checkHaikuSyllables;

@end
