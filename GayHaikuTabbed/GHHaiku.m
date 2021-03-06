//
//  GHHaiku.m
//  Gay Haiku
//
//  Created by Joel Derfner on 9/15/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import "GHHaiku.h"

@implementation GHHaiku

@synthesize gayHaiku, favoriteHaiku, justComposed, isUserHaiku, userIsEditing, text, newIndex, newFavoritesIndex, isFavorite;

-(void) loadHaiku {
    //This loads the haiku from gayHaiku.plist to the file "path".
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"gayHaiku413.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: path]) {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"gayHaiku413" ofType:@"plist"];
        [fileManager copyItemAtPath:bundle toPath: path error:&error];
    }
    NSString *oldPath = [documentsDirectory stringByAppendingPathComponent:@"gayHaiku.plist"];
    if ([fileManager fileExistsAtPath:oldPath]) {
        [fileManager removeItemAtPath:oldPath error:&error];
    }
    
    //UNCOMMENT, RUN, AND THEN RECOMMENT THIS SECTION IF NEED TO DELETE LOCAL HAIKU DOCUMENT (FOR TESTING USER-GENERATED HAIKU, ETC.).
    
    //     else if ([fileManager fileExistsAtPath: path]) {
    //        [fileManager removeItemAtPath:path error:&error];
    //     }
    
    
    //Loads an array with the contents of "path".
    
    self.haikuLoaded = [[NSMutableArray alloc] initWithContentsOfFile:path];
    
    //This loads the haiku from userHaiku.plist to the file "userPath".
    
    NSArray *userPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *userDocumentsDirectory = userPaths[0];
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
    BOOL f=NO;
    [self shuffle:f];
}

+ (GHHaiku *)sharedInstance {
    
    //Make GHHaiku a singleton class.
    
    static GHHaiku *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GHHaiku alloc] init];
    });
    return sharedInstance;
}

-(void)shuffle:(BOOL)favorites {
    
    //(Re)set the index to 0.
    
    //Shuffle array.
    
    if (favorites) {
        self.newFavoritesIndex=0;
        for (int i = self.favoriteHaiku.count - 1; i >= 0; --i) {
            int r = arc4random_uniform(self.favoriteHaiku.count);
            NSLog(@"Shuffling favorites from GHHaiku.m");
            [self.favoriteHaiku exchangeObjectAtIndex:i withObjectAtIndex:r];
        }
    }
    else {
        if (!self.gayHaiku) {
            self.gayHaiku = [[NSMutableArray alloc] initWithArray:self.haikuLoaded];
        }
        self.newIndex=0;
        for (int i = self.gayHaiku.count - 1; i >= 0; --i) {
            int r = arc4random_uniform(self.gayHaiku.count);
            NSLog(@"Shuffling haiku from GHHaiku.m");
            [self.gayHaiku exchangeObjectAtIndex:i withObjectAtIndex:r];
        }
    }
}

-(void)saveToDocsFolder:(NSString *)string {
    
    //Saves array of user haiku to plist in docs folder.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:string];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath: path]) {
        NSString *cat=@"user";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", cat];
        NSArray *filteredArray = [self.gayHaiku filteredArrayUsingPredicate:predicate];
        [filteredArray writeToFile:path atomically:YES];
    }
}

/*-(NSMutableArray *)gayHaiku {
 if (!self.gayHaiku) {
 self.gayHaiku = [[NSMutableArray alloc] initWithArray:self.haikuLoaded];
 }
 return self.gayHaiku;
 }*/

-(NSMutableArray *)favoriteHaiku {
    NSString *fav = @"yes";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favorite == %@", fav];
    NSArray *array = [self.gayHaiku filteredArrayUsingPredicate:predicate];
    self.favoriteHaiku = [array mutableCopy];
    return self.favoriteHaiku;
}

-(void)haikuToShowFavorites {
    
    //If you've gone through the entire array, empty the array of haiku seen and reset the index.
    
    BOOL favorites = YES;
    if (self.newFavoritesIndex==self.favoriteHaiku.count) {
        [self shuffle:favorites];
    }
    
    //Set the current text to be the text of the haiku at newIndex
    
    self.text = [self.favoriteHaiku[self.newFavoritesIndex] valueForKey:@"haiku"];
    
    //Indicate whether it's a user-generated haiku or not.
    
    NSString *cat = [self.favoriteHaiku[self.newFavoritesIndex] valueForKey:@"category"];
    if ([cat isEqualToString:@"user"]) {
        self.isUserHaiku=YES;
    }
    else {
        self.isUserHaiku=NO;
    }
}

-(void)haikuToShowAll {
    
    //If you've gone through the entire array, empty the array of haiku seen and reset the index.
    
    BOOL favorites = NO;
    if (self.newIndex==self.gayHaiku.count) {
        [self shuffle:favorites];
    }
    
    //Set the current text to be the text of the haiku at newIndex
    
    self.text = [self.gayHaiku[self.newIndex] valueForKey:@"haiku"];
    
    //Indicate whether it's a user-generated haiku or not.
    
    NSString *cat = [self.gayHaiku[self.newIndex] valueForKey:@"category"];
    if ([cat isEqualToString:@"user"]) {
        self.isUserHaiku=YES;
    }
    else {
        self.isUserHaiku=NO;
    }
}



@end
