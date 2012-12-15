//
//  GHVerify.m
//  Gay Haiku
//
//  Created by Joel Derfner on 12/1/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "GHVerify.h"

@implementation GHVerify

@synthesize listOfLines, ghhaiku, correctNumberOfLines, correctNumberOfSyllablesInFirstLine, correctNumberOfSyllablesInSecondLine, correctNumberOfSyllablesInThirdLine, linesAfterCheck;

-(NSArray *)splitHaikuIntoLines: (NSString *)haiku
{
    self.listOfLines = [[NSArray alloc] initWithArray:[haiku componentsSeparatedByString:@"\n"] ];
    return self.listOfLines;
}

-(int) syllablesInLine: (NSString *)line {
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
        self.correctNumberOfLines=@"your haiku seems to have too many lines.";
    }
    else if (self.listOfLines.count<3)
    {
        self.correctNumberOfLines=@"your haiku seems to have too few lines.";
    }
    else self.correctNumberOfLines=@"Just right.";
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
            NSString *tooFew = [NSString stringWithFormat:@"line %d might have too few syllables.",i+1];
            [self.linesAfterCheck addObject:tooFew];
        }
        else if (extant>ideal)
        {
            NSString *tooMany = [NSString stringWithFormat:@"line %d might have too many syllables.", i+1];
            [self.linesAfterCheck addObject:tooMany];
        }
        else if (extant==ideal)
        {
            [self.linesAfterCheck addObject:@"Just right."];
        }
    }
    return YES;
}

@end
