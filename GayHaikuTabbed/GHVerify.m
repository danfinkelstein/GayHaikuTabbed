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

-(NSArray *)splitHaikuIntoLines: (NSString *)haiku
{
    
    //Splits NSString into lines separated by \n character.
    
    self.listOfLines = [[NSArray alloc] initWithArray:[haiku componentsSeparatedByString:@"\n"] ];
    return self.listOfLines;
}

-(int) syllablesInLine: (NSString *)line {
    
    //Counts number of lines in haiku.
    
    int number = [line syllableCount];
    return number;
}

-(BOOL)checkHaikuSyllables
{
    if (!self.ghhaiku)
    {
        self.ghhaiku = [[GHHaiku alloc] init];
    }
    if (self.listOfLines.count>3)
    {
        self.numberOfLinesAsProperty=tooManyLines;
    }
    else if (self.listOfLines.count<3)
    {
        self.numberOfLinesAsProperty=tooFewLines;
    }
    else
    {
        self.numberOfLinesAsProperty = rightNumberOfLines;
    }
    self.linesAfterCheck = [[NSMutableArray alloc] init];
    NSArray *syllablesInLine = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:7], [NSNumber numberWithInt:5], nil ];

    int k;
    if (self.listOfLines.count<3)
    {
        k=self.listOfLines.count;
    }
    else
    {
        k=3;
    }
    for (int i=0; i<k; i++)
    {
        int extant = [self syllablesInLine:[self.listOfLines objectAtIndex:i]];
        int ideal = [[syllablesInLine objectAtIndex:i] integerValue];
        if (extant<ideal)
        {
            [self.linesAfterCheck addObject:@"too few"];
        }
        else if (extant>ideal)
        {
            [self.linesAfterCheck addObject:@"too many"];
        }
        else if (extant==ideal)
        {
            [self.linesAfterCheck addObject:@"Just right."];
        }
    }
    return YES;
}

@end
