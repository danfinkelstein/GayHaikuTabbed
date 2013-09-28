//
//  GHHaikuCollection.m
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 3/17/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import "GHHaikuCollection.h"
#import "GHHaikuInstance.h"
#import "GHAppDefaults.h"

@implementation GHHaikuCollection

@synthesize newIndex, newFavoritesIndex, arrayOfGayHaiku, arrayOfFavoriteHaiku, haikuLoaded, favoritesListSelected;

+(GHHaikuCollection *)sharedInstance {
    static GHHaikuCollection *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GHHaikuCollection alloc] init];
    });
    return sharedInstance;
}

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
    NSLog(@"mutArrUser:  %@",userPath);
    [self.haikuLoaded addObjectsFromArray:mutArrUser];
    BOOL f=NO;
    [self loadHaikuIntoArray];
    GHAppDefaults *userInfo = [GHAppDefaults sharedInstance];
    [userInfo setUserDefaults];
    if (userInfo.fourThirteenSeen) {
        [self shuffle:f];
    }
    else {
        userInfo.fourThirteenSeen=YES;
        [userInfo.defaults setBool:YES forKey:@"fourThirteenSeen?"];
        [userInfo.defaults synchronize];
    }
}

-(void)saveToDocsFolder:(NSString *)string {
    
    //Saves array of user haiku to plist in docs folder.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:string];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath: path]) {
        NSMutableArray *arrayToSaveToPath = [[NSMutableArray alloc] init];
        for (GHHaikuInstance *h in self.arrayOfGayHaiku) {
            if (h.isUserHaiku) {
                NSString *fav;
                if (h.isFavorite) fav=@"yes";
                else fav=@"no";
                NSArray *collectionOfHaiku = @[@"user",fav,h.text];
                NSArray *keys = @[@"category",@"favorite",@"haiku"];
                NSDictionary *dictToSave = [[NSDictionary alloc] initWithObjects:collectionOfHaiku forKeys:keys];
                [arrayToSaveToPath addObject:dictToSave];
            }
        }
        [arrayToSaveToPath writeToFile:path atomically:YES];
    }
}

-(void)loadHaikuIntoArray {
    self.arrayOfGayHaiku = [[NSMutableArray alloc] init];
    for (int i=0; i<self.haikuLoaded.count; i++) {
        
        GHHaikuInstance *instance = [[GHHaikuInstance alloc] init];
        instance.text = [self.haikuLoaded[i] valueForKey:@"haiku"];
        BOOL user;
        if ([[self.haikuLoaded[i] valueForKey:@"category"] isEqualToString:@"user"]) {
            user=YES;
        }
        else user=NO;
        instance.isUserHaiku=user;
        BOOL fav;
        if ([[self.haikuLoaded[i] valueForKey:@"favorite"] isEqualToString:@"yes"]) {
            fav=YES;
        }
        else fav=NO;
        instance.isFavorite=fav;
        [self.arrayOfGayHaiku addObject:instance];
        instance=NULL;
    }
}

-(NSMutableArray *)createArrayOfFavoriteHaiku {
    self.arrayOfFavoriteHaiku = [[NSMutableArray alloc] init];
    for (int i=0; i<self.arrayOfGayHaiku.count; i++) {
        GHHaikuInstance *inst = self.arrayOfGayHaiku[i];
        if (inst.isFavorite) {
            [self.arrayOfFavoriteHaiku addObject:inst];
        }
    }
    return self.arrayOfFavoriteHaiku;
}


-(void)shuffle:(BOOL)favorites {
    
    //Shuffle array.
    
    //if (favorites) {
    //  self.newFavoritesIndex=0;
    //for (int i = self.arrayOfFavoriteHaiku.count - 1; i >= 0; --i) {
    //  int r = arc4random_uniform(self.arrayOfFavoriteHaiku.count);
    //[self.arrayOfFavoriteHaiku exchangeObjectAtIndex:i withObjectAtIndex:r];
    //}
    //}
    //else {
    self.newIndex=0;
    for (int i = self.arrayOfGayHaiku.count - 1; i >= 0; --i) {
        int r = arc4random_uniform(self.arrayOfGayHaiku.count);
        NSLog(@"Shuffling haiku from GHHaikuCollection.m");
        [self.arrayOfGayHaiku exchangeObjectAtIndex:i withObjectAtIndex:r];
    }
    //}
}

-(GHHaikuInstance *)haikuToShowFavorites {
    self.arrayOfFavoriteHaiku = [self createArrayOfFavoriteHaiku];
    if (self.newFavoritesIndex!=0 && self.newFavoritesIndex>=self.arrayOfFavoriteHaiku.count) {
        //  BOOL favorites = YES;
        //[self shuffle:favorites];
        self.newFavoritesIndex=0;
    }
    GHHaikuInstance *haiku = [[GHHaikuInstance alloc] init];
    haiku = self.arrayOfFavoriteHaiku[self.newFavoritesIndex];
    return haiku;
}

-(GHHaikuInstance *)haikuToShowAll {
    if (self.newIndex!=0 && self.newIndex==self.arrayOfGayHaiku.count) {
        BOOL favorites = NO;
        [self shuffle:favorites];
    }
    GHHaikuInstance *haiku = [[GHHaikuInstance alloc] init];
    haiku = self.arrayOfGayHaiku[self.newIndex];
    return haiku;
}

@end
