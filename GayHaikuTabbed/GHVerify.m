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
    //self.listOfLines = ;
    NSLog(@"list of lines: %@", self.listOfLines);
    return self.listOfLines;
}

-(int) syllablesInLine: (NSString *)line {
    int number = [line syllableCount];
    NSLog(@"Syllables in line: %d",number);
    return number;
}

-(BOOL)checkHaikuSyllables
{
    if (!self.ghhaiku)
    {
        self.ghhaiku = [[GHHaiku alloc] init];
    }
    NSLog(@"list of lines: %@ count: %d",self.listOfLines, self.listOfLines.count);
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

    for (int i=0; i<3; i++)
    {
        int extant = [self syllablesInLine:[self.listOfLines objectAtIndex:i]];
        int ideal = [[syllablesInLine objectAtIndex:i] integerValue];
        NSLog(@"extant: %d ideal: %d",extant, ideal);
        if (extant<ideal)
        {
            NSString *tooFew = [NSString stringWithFormat:@"line %d seems to have too few syllables.",i+1];
            [self.linesAfterCheck addObject:tooFew];
        }
        else if (extant>ideal)
        {
            NSString *tooMany = [NSString stringWithFormat:@"line %d seems to have too many syllables.", i+1];
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
