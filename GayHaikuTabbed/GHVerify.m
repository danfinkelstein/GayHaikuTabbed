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

-(int) syllablesInLine: (NSString *)line {
    
                //Counts number of lines in haiku.
    
    //int number = [line syllableTotal];
    int number = [self syllableTotal:line];
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
        
        int extant = [self syllablesInLine:self.listOfLines[i]];
        
                //Create a variable representing the number of syllables that SHOULD be in that line.
        
        int ideal = [syllablesInLine[i] integerValue];
        
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

- (NSString*)cleanText: (NSString *)t {
    NSString *text = [t copy];
    // Strip tags
    text = [[NSRegularExpression simpleRegex:@"<[^>]+>"] stringByReplacingMatchesInString:text options:kNilOptions range:NSMakeRange(0, [text length]) withTemplate:@""];
    // Replace commas, hyphens, quotes etc (count them as spaces)
    text = [[NSRegularExpression simpleRegex:@"[,:;\\(\\)\\-]"] stringByReplacingMatchesInString:text options:kNilOptions range:NSMakeRange(0, [text length]) withTemplate:@""];
    // Unify terminators
    text = [[NSRegularExpression simpleRegex:@"[\\.\\!\\?]"] stringByReplacingMatchesInString:text options:kNilOptions range:NSMakeRange(0, [text length]) withTemplate:@"."];
    // trim whitespace
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    // add ending terminator if it's not there
    text = [text stringByAppendingString:@"."];
    // Replace new lines with spaces
    text = [[NSRegularExpression simpleRegex:@"[ ]*(\\n|\\r\\n|\\r)[ ]*"] stringByReplacingMatchesInString:text options:kNilOptions range:NSMakeRange(0, [text length]) withTemplate:@" "];
    // Check for duplicated terminators
    text = [[NSRegularExpression simpleRegex:@"\\.[\\.]+"] stringByReplacingMatchesInString:text options:kNilOptions range:NSMakeRange(0, [text length]) withTemplate:@"."];
    // Pad sentence terminators
    text = [[NSRegularExpression simpleRegex:@"[ ]*([\\.])\\s"] stringByReplacingMatchesInString:text options:kNilOptions range:NSMakeRange(0, [text length]) withTemplate:@". "];
    // Remove "words" comprised only of numbers
    text = [[NSRegularExpression simpleRegex:@"\\s[0-9]+\\s"] stringByReplacingMatchesInString:text options:kNilOptions range:NSMakeRange(0, [text length]) withTemplate:@" "];
    // Remove multiple spaces
    text = [[NSRegularExpression simpleRegex:@"\\s+$"] stringByReplacingMatchesInString:text options:kNilOptions range:NSMakeRange(0, [text length]) withTemplate:@" "];
    text = [[NSRegularExpression simpleRegex:@"\\s+"] stringByReplacingMatchesInString:text options:kNilOptions range:NSMakeRange(0, [text length]) withTemplate:@" "];
    return text;
}

- (NSInteger)syllableTotal: (NSString *)sg {
    NSString *cleanText = [self cleanText:sg];
    __block NSInteger syllableCount = 0;
    NSArray *words = [cleanText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [words enumerateObjectsUsingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@ %d",words[idx],[self syllableCount:word]);
        syllableCount += [self syllableCount:word];
    }];
    return syllableCount;
}

- (NSInteger)syllableCount: (NSString *)s {
    if ([s isEqualToString:@""]) {
        return 0;
    }
    
    // remove non-alpha chars
    NSString *strippedString = [s stringByReplacingRegularExpression:@"[^A-Za-z]" withString:@"" options:kNilOptions];
    // use lowercase for brevity w/ options + patterns
    NSString *lowercase = [strippedString lowercaseString];
    
    // altered in enumerate blocks
    __block NSInteger syllableCount = 0;
    
    // special rules that don't follow syllable matching patterns
    exceptions = [self loadSyllableCheckExceptions];
    
    // if one of the preceding words, return special case value
    NSNumber *caught = exceptions[lowercase];
    if (caught) {
        return caught.integerValue;
    }
    
    // These syllables would be counted as two but should be one
    NSArray *subSyllables = @[
    @"cial",
    @"tia",
    @"cius",
    @"cious",
    @"giu",
    @"ion",
    @"iou",
    @"sia$",
    @"[^aeiuoyt]{2}ed$",
    @".ely$",
    @"[cg]h?e[rsd]?$",
    @"rved?$",
    @"[aeiouy][dt]es?$",
    @"[aeiouy][^aeiouydt]e[rsd]?$",
    //"^[dr]e[aeiou][^aeiou]+$" // Sorts out deal deign etc
    @"[aeiouy]rse$",
    ];
    
    // These syllables would be counted as one but should be two
    NSArray *addSyllables = @[
    @"ia",
    @"riet",
    @"dien",
    @"iu",
    @"io",
    @"ii",
    @"[aeiouym]bl$",
    @"[aeiou]{3}",
    @"^mc",
    @"ism$",
    @"([^aeiouy])\1l$",
    @"[^l]lien",
    @"^coa[dglx].",
    @"[^gq]ua[^auieo]",
    @"dnt$",
    @"uity$",
    @"ie(r|st)$"
    ];
    
    // Single syllable prefixes and suffixes
    NSArray *prefixSuffix = @[
    @"^un",
    @"^fore",
    @"ly$",
    @"less$",
    @"ful$",
    @"ers?$",
    @"ings?$",
    ];
    
    // remove prefix & suffix, count how many are removed
    NSInteger prefixesSuffixesCount = 0;
    NSString *strippedPrefixesSuffixes = [NSRegularExpression stringByReplacingOccurenceOfPatterns:prefixSuffix inString:lowercase options:kNilOptions withTemplate:@"" count:&prefixesSuffixesCount];
    
    // removed non-word chars from word
    NSString *strippedNonWord = [strippedPrefixesSuffixes stringByReplacingRegularExpression:@"[^a-z]" withString:@"" options:kNilOptions];
    NSString *nonVowelPattern = @"[aeiouy]+";
    NSError *vowelError = nil;
    NSRegularExpression *nonVowelRegex = [[NSRegularExpression alloc] initWithPattern:nonVowelPattern options:kNilOptions error:&vowelError];
    NSArray *wordPartsResults = [nonVowelRegex matchesInString:strippedNonWord options:kNilOptions range:NSMakeRange(0, [strippedNonWord length])];
    
    NSMutableArray *wordParts = [NSMutableArray array];
    [wordPartsResults enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
        NSString *substr = [strippedNonWord substringWithRange:match.range];
        if (substr) {
            [wordParts addObject:substr];
        }
    }];
    
    __block NSInteger wordPartCount = 0;
    [wordParts enumerateObjectsUsingBlock:^(NSString *part, NSUInteger idx, BOOL *stop) {
        if (! [part isEqualToString:@""]) {
            wordPartCount++;
        }
    }];
    
    syllableCount = wordPartCount + prefixesSuffixesCount;
    
    // Some syllables do not follow normal rules - check for them
    // Thanks to Joe Kovar for correcting a bug in the following lines
    [subSyllables enumerateObjectsUsingBlock:^(NSString *subSyllable, NSUInteger idx, BOOL *stop) {
        NSError *error = nil;
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:subSyllable options:kNilOptions error:&error];
        syllableCount -= [regex numberOfMatchesInString:strippedNonWord options:kNilOptions range:NSMakeRange(0, [strippedNonWord length])];
    }];
    
    [addSyllables enumerateObjectsUsingBlock:^(NSString *addSyllable, NSUInteger idx, BOOL *stop) {
        NSError *error = nil;
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:addSyllable options:kNilOptions error:&error];
        syllableCount += [regex numberOfMatchesInString:strippedNonWord options:kNilOptions range:NSMakeRange(0, [strippedNonWord length])];
    }];
    
    syllableCount = syllableCount <= 0 ? 1 : syllableCount;
    return syllableCount;
}

-(NSDictionary *)loadSyllableCheckExceptions {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"exceptions"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: path]) {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"exceptions" ofType:@"plist"];
        [fileManager copyItemAtPath:bundle toPath: path error:&error];
    }
    
    //Loads an array with the contents of "path".
    
    NSDictionary *ex = [[NSDictionary alloc] initWithContentsOfFile:path];
    return ex;
}

@end
