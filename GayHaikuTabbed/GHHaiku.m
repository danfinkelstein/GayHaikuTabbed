//
//  GHHaiku.m
//  Gay Haiku
//
//  Created by Joel Derfner on 9/15/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import "GHHaiku.h"

@implementation GHHaiku

@synthesize arrayAfterFiltering, index, selectedCategory, gayHaiku,justComposed, isUserHaiku, userIsEditing, text, newIndex;

+ (GHHaiku *)sharedInstance

    //Make GHHaiku a singleton class.

{
    static GHHaiku *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GHHaiku alloc] init];
    });
    return sharedInstance;
}

-(int)chooseNumber: (int)blah

    //Choose a random number between 0 and the number of haiku in the array of all haiku, minus 1.

{
    int x;
    x = (arc4random() % blah);
    return x;
}

-(void)shuffle
{
    
    //(Re)set the index to 0.
    
    self.newIndex=0;
    
    //Populate a temporary array with the haiku in self.gayHaiku.
    
    NSMutableArray *arrayForShuffling = [[NSMutableArray alloc] initWithArray:self.gayHaiku];
    int arrayCount = arrayForShuffling.count;
    
    //Empty self.gayHaiku.
    
    self.gayHaiku = [[NSMutableArray alloc] init];
    
    //Repopulate self.gayHaiku randomly with the items it used to hold (items now in the temporary array).
    
    for (int i=0; i<arrayCount; i++)
    {
        int sortingHat = [self chooseNumber:arrayForShuffling.count];
        [self.gayHaiku addObject:[arrayForShuffling objectAtIndex:sortingHat]];
        [arrayForShuffling removeObjectAtIndex:sortingHat];
        if (arrayForShuffling.count>0)
        {
            [arrayForShuffling insertObject:[arrayForShuffling lastObject] atIndex:sortingHat];
            [arrayForShuffling removeLastObject];
        }
    }
}

-(void)haikuToShow

    //Choose the next haiku for GHHaikuViewController -(void)goToNextHaiku.

{
    //Create terms

    if (!self.newIndex) self.newIndex=0;
    if (!self.gayHaiku)
    {
        self.gayHaiku=[[NSMutableArray alloc] initWithArray:self.haikuLoaded];
        self.newIndex=0;
        [self shuffle];
    }
    
    //If you've gone through the entire array, empty the array of haiku seen and reset the index.
    
    if (self.newIndex==self.gayHaiku.count)
    {
        [self shuffle];
    }
    
    self.text = [[self.gayHaiku objectAtIndex:self.newIndex] valueForKey:@"quote"];
        
    //Indicate whether it's a user-generated haiku or not.
        
    if ([[[self.gayHaiku objectAtIndex:self.newIndex] valueForKey:@"category"] isEqualToString:@"user"])
    {
        self.isUserHaiku=YES;
    }
    else
    {
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
    if (![fileManager fileExistsAtPath: path])
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"gayHaiku" ofType:@"plist"];
        [fileManager copyItemAtPath:bundle toPath: path error:&error];
    }
    
    //UNCOMMENT, RUN, AND THEN RECOMMENT THIS SECTION IF NEED TO DELETE LOCAL HAIKU DOCUMENT (FOR TESTING USER-GENERATED HAIKU, ETC.).
    /*
     else if ([fileManager fileExistsAtPath: path])
     {
     [fileManager removeItemAtPath:path error:&error];
     }
     */
    
    //Loads an array with the contents of "path".
    
    self.haikuLoaded = [[NSMutableArray alloc] initWithContentsOfFile:path];
    
    //This loads the haiku from userHaiku.plist to the file "userPath".
    
    NSArray *userPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *userDocumentsDirectory = [userPaths objectAtIndex:0];
    NSString *userPath = [userDocumentsDirectory stringByAppendingPathComponent:@"userHaiku.plist"];
    NSFileManager *userFileManager = [NSFileManager defaultManager];
    if (![userFileManager fileExistsAtPath: userPath])
    {
        NSString *userBundle = [[NSBundle mainBundle] pathForResource:@"userHaiku" ofType:@"plist"];
        [userFileManager copyItemAtPath:userBundle toPath: userPath error:&error];
    }
    //UNCOMMENT, RUN, AND THEN RECOMMENT THIS SECTION IF NEED TO DELETE LOCAL HAIKU DOCUMENT (FOR TESTING USER-GENERATED HAIKU, ETC.).
    
    /*
     else if ([userFileManager fileExistsAtPath: userPath])
     {
     [userFileManager removeItemAtPath:userPath error:&error];
     }
     */
    
    //Loads an array with the contents of "userPath".

    NSMutableArray *mutArrUser = [[NSMutableArray alloc] initWithContentsOfFile:userPath];
    [self.haikuLoaded addObjectsFromArray:mutArrUser];
}

-(void)saveToDocsFolder:(NSString *)string
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:string];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath: path])
    {
        NSString *cat=@"user";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", cat];
        NSArray *filteredArray = [self.gayHaiku filteredArrayUsingPredicate:predicate];
        [filteredArray writeToFile:path atomically:YES];
    }
}

@end
