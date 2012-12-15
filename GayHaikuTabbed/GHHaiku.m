//
//  GHHaiku.m
//  Gay Haiku
//
//  Created by Joel Derfner on 9/15/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import "GHHaiku.h"

@implementation GHHaiku

@synthesize arrayOfSeen, arrayAfterFiltering, index, selectedCategory, gayHaiku,justComposed, isUserHaiku, userIsEditing, text;

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

-(int)chooseNumber

    //Choose a random number between 0 and the number of haiku in the array of all haiku, minus 1.

{
    int x;
    x = (arc4random() % self.gayHaiku.count);
    return x;
}

-(void)haikuToShow

    //Choose the next haiku for GHHaikuViewController -(void)goToNextHaiku.

{
    
    //Create terms
    
    NSString *txt;
    int sortingHat;
    if (!self.index) self.index=0;
    if (!self.arrayOfSeen) self.arrayOfSeen = [[NSMutableArray alloc] init];
    
    //If you've gone through the entire array, empty the array of haiku seen and reset the index.
    
    if (self.gayHaiku.count==self.arrayOfSeen.count)
    {
        [self.arrayOfSeen removeAllObjects];
        self.index=0;
    }

    //If you haven't called previousHaiku
        
    if (self.index == self.arrayOfSeen.count)
    {
        
        //Choose a number
        
        while (true)
        {
            sortingHat = [self chooseNumber];
                
            //Make sure you haven't already seen the haiku at the chosen number....
                                
            if (![self.arrayOfSeen containsObject:[self.gayHaiku objectAtIndex:sortingHat]])
            {
                break;
            }
        }
            
        //Set text to quote for chosen number
            
        txt = [[self.gayHaiku objectAtIndex:sortingHat] valueForKey:@"quote"];
        
        //Indicate whether it's a user-generated haiku or not.
        
        if ([[[self.gayHaiku objectAtIndex:sortingHat] valueForKey:@"category"] isEqualToString:@"user"])
        {
            self.isUserHaiku=YES;
        }
        else
        {
            self.isUserHaiku=NO;
        }
            
        //Add haiku to array of haiku seen.
            
        [self.arrayOfSeen addObject:[self.gayHaiku objectAtIndex:sortingHat]];
            
        //change index to new index
            
        self.index = self.arrayOfSeen.count;
            
        //If the haiku just chosen was the last available, start over.
            
//This code is repeated from the beginning of the method.  Is there a reason to have it both at the beginning and here?
         
        if (self.arrayOfSeen.count == self.gayHaiku.count)
        {
            [self.arrayOfSeen removeAllObjects];
            self.index=0;
        }
    }
        
    //If you HAVE called previousHaiku

    else
    {
        txt = [[self.arrayOfSeen objectAtIndex:self.index] valueForKey:@"quote"];
        if ([[[self.arrayOfSeen objectAtIndex:self.index] valueForKey:@"category"] isEqualToString: @"user"])
        {
            self.isUserHaiku=YES;
        }
        else
        {
            self.isUserHaiku=NO;
        }
        self.index += 1;
    }
    self.text = txt;
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
    
    NSMutableArray *mutArr = [[NSMutableArray alloc] initWithContentsOfFile: path];
    
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
    self.gayHaiku = [[NSMutableArray alloc] initWithArray:mutArr];
    [self.gayHaiku addObjectsFromArray:mutArrUser];
}

-(void)saveToDocsFolder:(NSString *)string
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
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
