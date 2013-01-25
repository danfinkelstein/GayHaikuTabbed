//
//  GHVerify.m
//  Gay Haiku
//
//  Created by Joel Derfner on 12/1/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "GHVerify.h"

@implementation GHVerify

@synthesize listOfLines, ghhaiku, linesAfterCheck, numberOfLinesAsProperty;

-(NSArray *)splitHaikuIntoLines: (NSString *)haiku {
    
                //Splits NSString into lines separated by \n character.
    
    self.listOfLines = [[NSArray alloc] initWithArray:[haiku componentsSeparatedByString:@"\n"] ];
    return self.listOfLines;
}

-(NSArray *)splitHaikuIntoWords: (NSString *)haiku {
    NSArray *listOfWords = [[NSArray alloc] initWithArray:[haiku componentsSeparatedByString:@" "]];
    return listOfWords;
}

//Thanks to Ryan Nystrom for the code in the RNTextStatistics category.

-(int) syllablesInLine: (NSString *)line {
    
                //Counts number of lines in haiku.
    
    int number = [line syllableTotal];
    return number;
}

-(BOOL)checkHaikuSyllables {

    self.ghhaiku = [GHHaiku sharedInstance];
    
                //Determine whether the haiku has too many lines, too few lines, or the correct number of lines.
    
    if (self.listOfLines.count>3) {
        self.numberOfLinesAsProperty=tooManyLines;
    }
    else if (self.listOfLines.count<3) {
        self.numberOfLinesAsProperty=tooFewLines;
    }
    else {
        self.numberOfLinesAsProperty = rightNumberOfLines;
    }
    
                //If the haiku has too few lines, limit the number of lines evaluated to the number of lines the haiku has.  Otherwise, evaluate three lines.
    
    int k;
    if (self.listOfLines.count<3) {
        k=self.listOfLines.count;
    }
    else {
        k=3;
    }
    
                //Create an array to hold evaluations of lines in the haiku.
    
    self.linesAfterCheck = [[NSMutableArray alloc] init];
    
                //Create an array to hold the correct number of syllables in the lines to evaluate against.
    
    NSArray *syllablesInLine = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:7], [NSNumber numberWithInt:5], nil ];
    
                //Evaluate the lines to make sure they have the correct number of syllables.
    
    for (int i=0; i<k; i++) {
        
                //Create a variable representing the number of syllables in a given line.
        
        int extant = [self syllablesInLine:[self.listOfLines objectAtIndex:i]];
        
                //Create a variable representing the number of syllables that SHOULD be in that line.
        
        int ideal = [[syllablesInLine objectAtIndex:i] integerValue];
        
                //Compare those two variables and add a record of the comparison to the array self.linesAfterCheck.
        
        if (extant<ideal) {
            [self.linesAfterCheck addObject:@"too few"];
        }
        else if (extant>ideal) {
            [self.linesAfterCheck addObject:@"too many"];
        }
        else if (extant==ideal) {
            [self.linesAfterCheck addObject:@"just right"];
        }
    }
    return YES;
}

@end
