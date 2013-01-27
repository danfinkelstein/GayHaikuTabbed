//
//  GHHaiku.m
//  Gay Haiku
//
//  Created by Joel Derfner on 9/15/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import "GHHaiku.h"

@implementation GHHaiku

@synthesize gayHaiku, justComposed, isUserHaiku, userIsEditing, text, newIndex;

+ (GHHaiku *)sharedInstance {
    
                //Make GHHaiku a singleton class.

    static GHHaiku *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GHHaiku alloc] init];
    });
    return sharedInstance;
}

-(int)chooseNumber: (int)howManyHaiku {
    
                //Choose a random number between 0 and a given number of haiku.

    int x;
    //x = (arc4random() % howManyHaiku);
    x = arc4random_uniform(howManyHaiku);
    return x;
}

-(void)shuffle {
    
                //(Re)set the index to 0.
    
    self.newIndex=0;
    
                //Shuffle array.
    
    for (int i = self.gayHaiku.count - 1; i >= 0; --i) {
        int r = arc4random_uniform(self.gayHaiku.count);
        [self.gayHaiku exchangeObjectAtIndex:i withObjectAtIndex:r];
    }
    
    /*
     
                //Populate a temporary array with the haiku that self.gayHaiku contains.
     
    NSMutableArray *arrayForShuffling = [[NSMutableArray alloc] initWithArray:self.gayHaiku];
    int arrayCount = arrayForShuffling.count;
    
                //Empty self.gayHaiku.
    
    self.gayHaiku = [[NSMutableArray alloc] init];
    
                //Repopulate self.gayHaiku randomly with the items it used to hold (items now in the temporary array arrayForShuffling).
    
    for (int i=0; i<arrayCount; i++) {
        int sortingHat = [self chooseNumber:arrayForShuffling.count];
        [self.gayHaiku addObject:[arrayForShuffling objectAtIndex:sortingHat]];
        [arrayForShuffling removeObjectAtIndex:sortingHat];
        if (arrayForShuffling.count>0) {
            [arrayForShuffling insertObject:[arrayForShuffling lastObject] atIndex:sortingHat];
            [arrayForShuffling removeLastObject];
        }
    }*/
}

-(void)haikuToShow {

                //If properties haven't been created before, create them.

    if (!self.gayHaiku) {
        self.gayHaiku = [[NSMutableArray alloc] initWithArray:self.haikuLoaded];
        //self.newIndex=0;
        [self shuffle];
    }
    /*if (!self.newIndex) {
        self.newIndex=0;
    }*/
    
                //If you've gone through the entire array, empty the array of haiku seen and reset the index.
    
    if (self.newIndex==self.gayHaiku.count) {
        [self shuffle];
    }
    
                //Set the current text to be the text of the haiku at newIndex
    
    self.text = [[self.gayHaiku objectAtIndex:self.newIndex] valueForKey:@"haiku"];
        
                //Indicate whether it's a user-generated haiku or not.
    
    NSString *cat = [[self.gayHaiku objectAtIndex:self.newIndex] valueForKey:@"category"];
    if ([cat isEqualToString:@"user"]) {
        self.isUserHaiku=YES;
    }
    else {
        self.isUserHaiku=NO;
    }
}

-(void) loadHaiku
{
                //This loads the haiku from gayHaiku.plist to the file "path".
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"gayHaiku.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: path]) {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"gayHaiku" ofType:@"plist"];
        [fileManager copyItemAtPath:bundle toPath: path error:&error];
    }
    
                //UNCOMMENT, RUN, AND THEN RECOMMENT THIS SECTION IF NEED TO DELETE LOCAL HAIKU DOCUMENT (FOR TESTING USER-GENERATED HAIKU, ETC.).
    
//     else if ([fileManager fileExistsAtPath: path]) {
//        [fileManager removeItemAtPath:path error:&error];
//     }
    
    
                //Loads an array with the contents of "path".
    
    self.haikuLoaded = [[NSMutableArray alloc] initWithContentsOfFile:path];
    
                //This loads the haiku from userHaiku.plist to the file "userPath".
    
    NSArray *userPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *userDocumentsDirectory = [userPaths objectAtIndex:0];
    NSString *userPath = [userDocumentsDirectory stringByAppendingPathComponent:@"userHaiku.plist"];
    NSFileManager *userFileManager = [NSFileManager defaultManager];
    if (![userFileManager fileExistsAtPath: userPath]) {
        NSString *userBundle = [[NSBundle mainBundle] pathForResource:@"userHaiku" ofType:@"plist"];
        [userFileManager copyItemAtPath:userBundle toPath: userPath error:&error];
    }
    
                //UNCOMMENT, RUN, AND THEN RECOMMENT THIS SECTION IF NEED TO DELETE LOCAL HAIKU DOCUMENT (FOR TESTING USER-GENERATED HAIKU, ETC.).
    
    
//     else if ([userFileManager fileExistsAtPath: userPath]) {
//     [userFileManager removeItemAtPath:userPath error:&error];
//     }
    
    
                //Loads an array with the contents of "userPath".

    NSMutableArray *mutArrUser = [[NSMutableArray alloc] initWithContentsOfFile:userPath];
    [self.haikuLoaded addObjectsFromArray:mutArrUser];
}

-(void)saveToDocsFolder:(NSString *)string {
    
                //Saves array of user haiku to plist in docs folder.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:string];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath: path]) {
        NSString *cat=@"user";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", cat];
        NSArray *filteredArray = [self.gayHaiku filteredArrayUsingPredicate:predicate];
        [filteredArray writeToFile:path atomically:YES];
    }
}

@end
