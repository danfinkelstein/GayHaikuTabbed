//
// GHHaikuViewController.m
// Gay Haiku
//
// Created by Joel Derfner on 12/2/12.
// Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import "GHHaikuViewController.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "GHAppDefaults.h"
#import "GHVerify.h"
#import "DMActivityInstagram.h"
#import "GHHaikuInstance.h"

@interface GHHaikuViewController ()<UITextViewDelegate,UIGestureRecognizerDelegate,UITabBarControllerDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) GHHaikuInstance *haiku;
@property (strong, nonatomic) GHAppDefaults *userInfo;
@property (strong, nonatomic) UINavigationBar *navBar;
@property (strong, nonatomic) UITextView *displayHaikuTextView;
@property (strong, nonatomic) UITextView *leftSwipe;
@property (strong, nonatomic) UITextView *rightSwipe;
@property (nonatomic) BOOL appIsComingFromPreviousHaiku;
@property (nonatomic) BOOL rightSwipeHasBeenSeen;
@property (nonatomic) BOOL leftSwipeHasBeenSeen;

@end

@implementation GHHaikuViewController

@synthesize haikuCollection;

#pragma mark CREATION/SETUP METHODS

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    UIImageView *background;
    [self.view addSubview:background];
    screenHeight = self.view.bounds.size.height;
    screenWidth = self.view.bounds.size.width;
    
    //Add the UIImageView that corresponds to the size of the iPhone, and add the background image
    
    CGRect frame;
    frame = CGRectMake(0, 0, screenWidth, (screenHeight-TAB_BAR_HEIGHT));
    background = [[UIImageView alloc] initWithFrame:frame];
    background.image = screenHeight<500 ? [UIImage imageNamed:@"main.png"]:[UIImage imageNamed:@"5main.png"];
    [self.view addSubview:background];
    
    //Create and add gesture recognizers. Swiping from the right calls goToNextHaiku; swiping from the left calls goToPreviousHaiku. Tapping calls showNavBarOnTap.
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goToPreviousHaiku)];
    swipeRight.numberOfTouchesRequired = 1;
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goToNextHaiku)];
    swipeLeft.numberOfTouchesRequired = 1;
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UITapGestureRecognizer *tapBar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createNavBar)];
    [self.view addGestureRecognizer:tapBar];
    
    //Load array of haiku
    
    self.haikuCollection = [GHHaikuCollection sharedInstance];
    [self.haikuCollection loadHaiku];
    self.userInfo = [GHAppDefaults sharedInstance];
    [self.userInfo setUserDefaults];
    self.haikuCollection.favoritesListSelected=NO;
    
    //Add Parse
    
    [Parse setApplicationId:@"M7vcXO7ccmhNUbnLhmfnnmV8ezLvvuMvHwNZXrs8"
                  clientKey:@"Aw8j7MhJwsHxW1FxoHKuXojNGvrPSjDkACs7egRi"];
    
    //Set up tab bar
    
    //This code seems to have been obviated here by putting it in GHTabBarController.m.
    
    /*if (NSFoundationVersionNumber>NSFoundationVersionNumber_iOS_6_1) {
     //iOS7 code
     self.navBar.barTintColor = self.userInfo.screenColorTrans;
     self.navBar.tintColor = [UIColor colorWithRed:227/255.0 green:180/255.0 blue:204/255.0 alpha:1];;
     }
     else {
     //iOS6 code
     [[UITabBar appearance] setBarTintColor:self.userInfo.screenColorTrans];
     [[UITabBar appearance] setTintColor:[UIColor colorWithRed:227/255.0 green:180/255.0 blue:204/255.0 alpha:1]];
     }*/
    
    
    self.tabBarController.delegate=self;
    
    //Indicate that "swipe" text for previous/next have not been seen yet this session
    
    self.rightSwipeHasBeenSeen=NO;
    self.leftSwipeHasBeenSeen=NO;
    
    //Display first haiku and show (and fade) the nav bar
    //[self displayHaiku];
    //[self createNavBar];
    self.userInfo = [GHAppDefaults sharedInstance];
}

//Hide status bar.

- (BOOL)prefersStatusBarHidden {
    return YES;
}

+(GHHaikuViewController *)sharedInstance {
    static GHHaikuViewController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GHHaikuViewController alloc] init];
    });
    return sharedInstance;
}

-(UITextView *)createSwipeToAdd {
    
    //Create "Swipe" text and its characteristics
    
    UITextView *instructions = [[UITextView alloc] init];
    instructions.editable = NO;
    instructions.userInteractionEnabled = NO;
    instructions.textColor = self.userInfo.screenColorOp;
    instructions.backgroundColor = [UIColor clearColor];
    instructions.text = @"Swipe";
    instructions.font = [UIFont fontWithName:@"Zapfino" size:17];
    return instructions;
}

- (void)viewWillAppear:(BOOL)animated {
    
    //When the user returns from the compose screen having just composed a new haiku, replace whatever haiku was showing before with the new user haiku.
    [super viewWillAppear:animated];
    [self displayHaiku];
    [self createNavBar];
    self.haiku.userIsEditing = NO;
}

-(void)createNavBar {
    
    //Remove the nav bar if it exists.
    
    [self.navBar removeFromSuperview];
    
    //Create UINavigationBar. The reason this isn't lazily instantiated is to remove the glitch whereby, if the user has tapped a user haiku and shown the trash/edit buttons in the nav bar, the next non-user haiku tapped shows those buttons momentarily before they disappear.
    
    self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, TOOLBAR_HEIGHT)];
    
    if (NSFoundationVersionNumber>NSFoundationVersionNumber_iOS_6_1) {
        //iOS7 code
        self.navBar.barTintColor = self.userInfo.screenColorTrans;
        self.navBar.tintColor = [UIColor colorWithRed:227/255.0 green:180/255.0 blue:204/255.0 alpha:1];
    }
    else {
        //iOS6 code
        self.navBar.tintColor = self.userInfo.screenColorTrans;
    }
    self.navBar.translucent = YES;
    
    //Create UINavigationItem
    
    UINavigationItem *titleBar = [[UINavigationItem alloc] init];
    
    //Add share button and, if appropriate, delete and edit buttons
    
    UIBarButtonItem *send = [self addShareButton];
    UIBarButtonItem *changeFavoriteStatus = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"02-star.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(changeFavoriteStatus)];
    NSString *title;
    if (self.haikuCollection.favoritesListSelected) title=@"All";
    else title = @"Favorites";
    UIBarButtonItem *chooseFrom = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:NSSelectorFromString(@"chooseDatabase")];
    
    titleBar.rightBarButtonItems = @[send,chooseFrom,changeFavoriteStatus];
    
    if (self.haiku.isUserHaiku==YES) {
        NSArray *leftItems = [self addLeftButtons];
        titleBar.leftBarButtonItems = leftItems;
    }
    
    //Add navigation bar to screen.
    
    [self.navBar pushNavigationItem:titleBar animated:YES];
    [self.view addSubview:self.navBar];
    
    //Fade navigation bar: first delay, so that buttons are pressable, then fade.
    
    double delayInSeconds = 3.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:.5
                         animations:^{
                             self.navBar.alpha = 0;
                         }];
    });
}

-(UIBarButtonItem *)addShareButton {
    
    //Add a button allowing the user to share the haiku via Facebook, Twitter, or email.
    
    UIBarButtonItem *send = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
    send.style = UIBarButtonItemStyleBordered;
    return send;
}

-(void)changeFavoriteStatus {
    
    //Create the dictionary item of the new haiku to save in userHaiku.plist.
    self.haiku.isFavorite = !self.haiku.isFavorite;
    
    self.haikuCollection.arrayOfFavoriteHaiku = [self.haikuCollection createArrayOfFavoriteHaiku];
    
    //if (self.haiku.isFavorite) [self.haikuCollection.arrayOfFavoriteHaiku addObject:self.haiku];
    //else [self.haikuCollection.arrayOfFavoriteHaiku removeObject:self.haiku];
    
    //Save the haiku to the plist.
    if (self.haiku.isUserHaiku) [self.haikuCollection saveToDocsFolder:@"userHaiku.plist"];
    else [self.haikuCollection saveToDocsFolder:@"gayHaiku413.plist"];
    
    NSString *title;
    if (self.haiku.isFavorite) title = @"This haiku has been added to your Favorites list.";
    else title = @"This haiku has been removed from your Favorites list.";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:title delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void)chooseDatabase {
    if (self.haikuCollection.arrayOfFavoriteHaiku.count>0) self.haikuCollection.favoritesListSelected = !self.haikuCollection.favoritesListSelected;
    [self createNavBar];
}

-(NSArray *)addLeftButtons {
    
    //Add buttons allowing the user to delete and/or edit haiku s/he's composed.
    
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteHaiku)];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editHaiku)];
    NSArray *leftItems = @[editButton, deleteButton];
    return leftItems;
}

#pragma mark DISPLAY METHODS

-(int)measureWidthOfTextView {
    GHVerify *verify = [[GHVerify alloc] init];
    float widthOfLongestLineSoFar = 0.0;
    NSArray *lines = [verify splitHaikuIntoLines:self.haiku.text];
    for (int i = 0; i < lines.count; i++) {
        CGSize sizeOfLine = [verify.listOfLines[i] sizeWithFont:[UIFont fontWithName:@"Georgia" size:15]];
        float widthOfLineUnderConsideration = sizeOfLine.width;
        if (widthOfLongestLineSoFar<widthOfLineUnderConsideration) {
            widthOfLongestLineSoFar = widthOfLineUnderConsideration;
        }
    }
    int textWidth = widthOfLongestLineSoFar;
    return textWidth;
}

-(void)displayHaiku {
    
    //Empty screen
    
    [self.displayHaikuTextView removeFromSuperview];
    
    //Produce self.ghhaiku.text as the new haiku.
    
    if (self.haikuCollection.arrayOfFavoriteHaiku.count<1) self.haikuCollection.favoritesListSelected=NO;
    
    self.haikuCollection=[GHHaikuCollection sharedInstance];
    self.haiku = [[GHHaikuInstance alloc] init];
    if (self.haikuCollection.favoritesListSelected) self.haiku = [self.haikuCollection haikuToShowFavorites];
    else self.haiku = [self.haikuCollection haikuToShowAll];
    
    //Set CGSize so that haiku can be laid out in the center.
    
    CGSize dimensions = CGSizeMake(screenWidth, screenHeight);
    CGSize xySize = [self.haiku.text sizeWithFont:[UIFont fontWithName:@"Georgia" size:15] constrainedToSize:dimensions lineBreakMode:0];
    int textHeight = xySize.height+16;
    int textWidth = [self measureWidthOfTextView];
    
    //Set UITextView and its characteristics
    
    self.displayHaikuTextView = [self createTextViewForDisplay:self.haiku.text];
    self.displayHaikuTextView.frame = CGRectMake((screenWidth/2)-(textWidth/2),0.36*screenHeight,textWidth/2 + screenWidth/2,textHeight*2);
    
    //Set animation
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    
    //Set direction of animation depending on whether we're going to a previous or a next haiku.
    
    transition.subtype = (self.appIsComingFromPreviousHaiku==NO) ? kCATransitionFromRight : kCATransitionFromLeft;
    transition.delegate = self;
    [self.displayHaikuTextView.layer addAnimation:transition forKey:nil];
    
    //Add text to view.
    
    [self.view addSubview:self.displayHaikuTextView];
    
    //Remove navBar from view, just in case delete/edit version has been showing for user-generated haiku, so that user can't accidentally delete or edit default haiku.
    
    [self.navBar removeFromSuperview];
    
    //Show swipe for next/swipe for previous instructions if appropriate (and adjust booleans accordingly; remove them if appropriate.
    
    if (self.rightSwipeHasBeenSeen==NO) {
        [self addSwipeForNextView];
        self.rightSwipeHasBeenSeen=YES;
    }
    else {
        [self.rightSwipe removeFromSuperview];
    }
    if (self.leftSwipeHasBeenSeen==YES) {
        [self.leftSwipe removeFromSuperview];
    }
}

-(void)addSwipeForNextView {
    
    //Create "swipe" message to be shown with first haiku and set its location.
    
    self.rightSwipe = [self createSwipeToAdd];
    CGSize xySize = [self.rightSwipe.text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:17]];
    
    //We need xySize.width*1.5 and xySize.height*2 because using just xySize.width and xySize.height cuts off the text--UITextView has padding built in.
    
    CGRect rect = CGRectMake((screenWidth - xySize.width-30), screenHeight-240, xySize.width*1.5, xySize.height*2);
    self.rightSwipe.frame = rect;
    
    //Display it.
    
    [self.view addSubview:self.rightSwipe];
}

-(void)addSwipeForPreviousView {
    
    //Create "swipe" message to be shown with second haiku and set its location.
    
    self.leftSwipe = [self createSwipeToAdd];
    CGSize xySize = [self.leftSwipe.text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:17]];
    
    //We need xySize.width*1.5 and xySize.height*2 because using just xySize.width and xySize.height cuts off the text--UITextView has padding built in.
    
    CGRect rect = CGRectMake(10, screenHeight-240, xySize.width*1.5, xySize.height*2);
    self.leftSwipe.frame = rect;
    
    //Display it
    
    [self.view addSubview:self.leftSwipe];
}

#pragma mark NAVIGATION METHODS

-(void)goToNextHaiku {
    
    //Increase the index by one.
    if (self.haikuCollection.favoritesListSelected) self.haikuCollection.newFavoritesIndex++;
    else self.haikuCollection.newIndex++;
    
    //Set boolean for direction of animation.
    
    self.appIsComingFromPreviousHaiku = NO;
    
    //Show next haiku in array
    
    [self displayHaiku];
    
    //Show swipe instructions if appropriate and adjust booleans accordingly
    
    if (self.leftSwipeHasBeenSeen==NO) {
        [self addSwipeForPreviousView];
        self.leftSwipeHasBeenSeen = YES;
    }
    else {
        [self.leftSwipe removeFromSuperview];
    }
}

-(void)goToPreviousHaiku {
    
    //Reduce the index by one, if it can be so reduced.
    
    if (self.haikuCollection.favoritesListSelected) {
        if (!self.haikuCollection.newFavoritesIndex<1)
        {
            self.haikuCollection.newFavoritesIndex--;
        }
        else {
            self.haikuCollection.newFavoritesIndex = self.haikuCollection.arrayOfFavoriteHaiku.count-1;
        }
    }
    
    if (!self.haikuCollection.newIndex<1)
    {
        self.haikuCollection.newIndex--;
    }
    else {
        self.haikuCollection.newIndex = self.haikuCollection.arrayOfGayHaiku.count-1;
    }
    
    //Set boolean for direction of animation
    
    self.appIsComingFromPreviousHaiku=YES;
    
    //Display the haiku.
    
    [self displayHaiku];
}

#pragma mark ADDITION/DELETION METHODS

-(void)editHaiku {
    
    //Indicate we're in editing mode and go to the compose screen.
    
    self.haiku.userIsEditing = YES;
    self.tabBarController.selectedIndex = 1;
}

-(void)deleteHaiku {
    
    if (self.haiku.isUserHaiku) {
        
        //Delete the haiku from the array of haiku.
        
        if (!self.haikuCollection.favoritesListSelected) {
            
            if (self.haikuCollection.arrayOfGayHaiku.count != 0) {
                [self.haikuCollection.arrayOfGayHaiku removeObjectAtIndex:self.haikuCollection.newIndex];
            }
        }
        
        else {
            
            if (self.haikuCollection.arrayOfFavoriteHaiku.count != 0)
                
                [self.haikuCollection.arrayOfFavoriteHaiku removeObjectAtIndex:self.haikuCollection.newFavoritesIndex];
            for (GHHaikuInstance *h in self.haikuCollection.arrayOfGayHaiku) {
                if ([h.text isEqualToString:self.haiku.text]) {
                    [self.haikuCollection.arrayOfGayHaiku removeObjectIdenticalTo:h];
                }
            }
        }
        
        //Clear the screen
        
        [self.displayHaikuTextView removeFromSuperview];
        [self.navBar removeFromSuperview];
        
        //Save the new set of user haiku, now missing the deleted haiku, to the docs folder.
        
        [self.haikuCollection saveToDocsFolder:@"userHaiku.plist"];
        
        //Display next haiku so the screen won't be blank.
        
        [self displayHaiku];
    }
}

#pragma mark SHARING METHODS

-(void)share {
    DMActivityInstagram *activity = [[DMActivityInstagram alloc] init];
    UIImage *myImage = [self addTextToImage:[UIImage imageNamed:@"backgroundForShare.png"] withFontSize:24];
    NSURL *shareURL = [NSURL URLWithString:@"http://appstore.com/gayhaiku"];
    NSArray *activityItems = @[myImage, shareURL];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:@[activity]];
    activityController.excludedActivityTypes=@[UIActivityTypeAssignToContact,UIActivityTypeMessage,UIActivityTypePostToWeibo,UIActivityTypeCopyToPasteboard];
    [self presentViewController:activityController animated:YES completion:nil];
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
    UIActivity *activity;
    [activity activityDidFinish:YES];
}


//Using a magic number here to try to eliminate font size weirdness that happens when playing MTGetaways 2.

-(UITextView *)createTextViewForDisplay:(NSString *)s {
    UITextView *tv = [[UITextView alloc] init];
    tv.font = [UIFont fontWithName:@"Georgia" size : 15];
    tv.editable = NO;
    tv.userInteractionEnabled = NO;
    tv.backgroundColor = [UIColor clearColor];
    tv.text = s;
    return tv;
}

-(UIImage *)addTextToImage:(UIImage *)myImage withFontSize:(int)sz {
    GHVerify *ghv = [[GHVerify alloc] init];
    NSString *string = [ghv removeAuthor:self.displayHaikuTextView.text];
    NSString *myWatermarkText = [string stringByAppendingString:@"\n\n\t--appstore.com/gayhaiku"];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Georgia" size:sz], NSFontAttributeName, nil];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:myWatermarkText attributes:attrs];
    UIGraphicsBeginImageContextWithOptions(myImage.size,NO,1.0);
    [myImage drawAtPoint: CGPointZero];
    NSString *longestLine = ghv.listOfLines[1];
    CGSize sizeOfLongestLine = [longestLine sizeWithFont:[UIFont fontWithName:@"Georgia" size:sz]];
    CGSize siz = CGSizeMake(sizeOfLongestLine.width, sizeOfLongestLine.height*4);
    [attString drawAtPoint: CGPointMake(myImage.size.width/2 - siz.width/2, myImage.size.height/2-siz.height/2)];
    myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return myImage;
}

@end