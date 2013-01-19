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
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>
#import <Twitter/TWTweetComposeViewController.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Parse/Parse.h>
#import <Social/Social.h>
#import "GHAppDefaults.h"



@interface GHHaikuViewController ()<UITextViewDelegate,MFMailComposeViewControllerDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate, UITabBarControllerDelegate>

@end

@implementation GHHaikuViewController

@synthesize ghhaiku;

#pragma mark CREATION/SETUP METHODS

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    background.backgroundColor = [UIColor whiteColor];
    screenColor = [UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:.75];
    self.view.autoresizesSubviews=YES;
    [self.view addSubview:background];
    NSLog(@"View loaded.");
   [self setWidthAndHeight];
    
                //Add the UIImageView that corresponds to the size of the iPhone, and add the background image
    
    CGRect frame;
    frame = CGRectMake(0, 0, screenWidth, (screenHeight-tabBarHeight));
    background = [[UIImageView alloc] initWithFrame:frame];
    if (screenHeight<500) {
        background.image=[UIImage imageNamed:@"main.png"];
    }
    else {
        background.image=[UIImage imageNamed:@"5main.png"];
    }
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
    
    UITapGestureRecognizer *tapBar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNavBarOnTap)];
    [self.view addGestureRecognizer:tapBar];
    
                //Load array of haiku
    
    self.ghhaiku = [GHHaiku sharedInstance];
    [self.ghhaiku loadHaiku];
    
                //Add Parse
    
    [Parse setApplicationId:@"M7vcXO7ccmhNUbnLhmfnnmV8ezLvvuMvHwNZXrs8"
                  clientKey:@"Aw8j7MhJwsHxW1FxoHKuXojNGvrPSjDkACs7egRi"];
    
                //Set up tab bar
    
    [[UITabBar appearance] setTintColor:screenColor];
    self.tabBarController.delegate=self;
    
                //Indicate that "swipe" text for previous/next have not been seen yet this session
    
    rightSwipeSeen=NO;
    leftSwipeSeen=NO;
    
                //Display first haiku and show (and fade) the nav bar
    
    [self displayHaiku];
    [self showNavBarOnTap];
    
}

-(UITextView *)createSwipeToAdd: (NSString *)word {
    
                //Create "Swipe" text and its characteristics
    
    UITextView *instructions = [[UITextView alloc] init];
    instructions.editable=NO;
    instructions.userInteractionEnabled=NO;
    instructions.textColor = screenColor;
    instructions.alpha=1;
    instructions.backgroundColor = [UIColor clearColor];
    instructions.text = word;
    instructions.font = [UIFont fontWithName:@"Zapfino" size:largeFontSize];
    return instructions;
}

- (void)viewWillAppear:(BOOL)animated {
    
                //When the user returns from the compose screen having just composed a new haiku, replace whatever haiku was showing before with the new user haiku.
    
    if (self.ghhaiku.justComposed==YES)
    {
        [super viewWillAppear:animated];
        [self displayHaiku];
        [self showNavBarOnTap];
        self.ghhaiku.justComposed=NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)showNavBarOnTap {
    
                //Remove the nav bar if it exists.
    
    if (navBar) {
        [navBar removeFromSuperview];
    }
    
                //Create UINavigationBar. The reason this isn't lazily instantiated is to remove the glitch whereby, if the user has tapped a user haiku and shown the trash/edit buttons in the nav bar, the next non-user haiku tapped shows those buttons momentarily before they disappear.
    
    navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, toolbarHeight)];
    [navBar setTintColor:screenColor];
    
                //Create UINavigationItem
    
    titleBar = [[UINavigationItem alloc] init];
    
                //Add share button and, if appropriate, delete and edit buttons
    
    [self addShareButton];
    if (self.ghhaiku.isUserHaiku==YES) {
        [self addLeftButtons];
    }
    
                //Add navigation bar to screen.
    
        [navBar pushNavigationItem:titleBar animated:YES];
        [self.view addSubview:navBar];
    
                //Fade navigation bar: first delay, so that buttons are pressable, then fade.
    
    double delayInSeconds = 3.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:.5
                         animations:^{
                             navBar.alpha = 0;
                         }];
    });
}

-(void)addShareButton {
    
                //Add a button allowing the user to share the haiku via Facebook, Twitter, or email.
    
    UIBarButtonItem *send = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showMessage)];
    send.style=UIBarButtonItemStyleBordered;
    titleBar.rightBarButtonItem = send;
}

-(void)setWidthAndHeight {
    screenWidth = self.view.bounds.size.width;
    screenHeight = self.view.bounds.size.height;
}

-(void)addLeftButtons {
    
                //Add buttons allowing the user to delete and/or edit haiku s/he's composed.
    
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteHaiku)];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editHaiku)];
    NSArray *leftItems = [[NSArray alloc] initWithObjects:editButton, deleteButton, nil];
    titleBar.leftBarButtonItems = leftItems;
}

#pragma mark DISPLAY METHODS

-(void)displayHaiku {
    
                //Empty screen
    
    [displayHaikuTextView removeFromSuperview];
    
                //Produce self.ghhaiku.text as the new haiku.
    
    self.ghhaiku=[GHHaiku sharedInstance];
    [self.ghhaiku haikuToShow];

                    //Set CGSize so that haiku can be laid out in the center.
    
    CGSize dimensions = CGSizeMake(screenWidth, screenHeight);
    CGSize xySize = [self.ghhaiku.text sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:mediumFontSize] constrainedToSize:dimensions lineBreakMode:0];
    
//If this is a problem, replace mediumFontSize in above line with largeFontSize.
    
    int textWidth = xySize.width+16;
    int textHeight = xySize.height+16;
    
                //Set UITextView and its characteristics
    
    displayHaikuTextView = [[UITextView alloc] init];
    displayHaikuTextView.backgroundColor = [UIColor clearColor];
    displayHaikuTextView.editable=NO;
    displayHaikuTextView.userInteractionEnabled=NO;
    displayHaikuTextView.font=[UIFont fontWithName:@"Helvetica Neue" size:mediumFontSize];
    displayHaikuTextView.text=self.ghhaiku.text;
    [displayHaikuTextView setFrame:CGRectMake((screenWidth/2)-(xySize.width/2),screenHeight/2-xySize.height,textWidth,textHeight)];
 
                //Set animation
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    
                //Set direction of animation depending on whether we're going to a previous or a next haiku.
    
    if (comingFromPrevious==NO) {
        transition.subtype =kCATransitionFromRight;
    }
    else {
        transition.subtype=kCATransitionFromLeft;
    }
    transition.delegate = self;
    [displayHaikuTextView.layer addAnimation:transition forKey:nil];
    
                //Add text to view.
    
    [self.view addSubview:displayHaikuTextView];
    
                //Remove navBar from view, just in case delete/edit version has been showing for user-generated haiku, so that user can't accidentally delete or edit default haiku.
    
    [navBar removeFromSuperview];
    
                //Show swipe for next/swipe for previous instructions if appropriate (and adjust booleans accordingly; remove them if appropriate.
    
    if (rightSwipeSeen==NO) {
        [self addSwipeForNextView];
        rightSwipeSeen=YES;
    }
    else {
        [rightSwipe removeFromSuperview];
    }
    if (leftSwipeSeen==YES) {
        [leftSwipe removeFromSuperview];
    }
}

-(void)addSwipeForNextView {
    
                //Create "swipe" message to be shown with first haiku and set its location.
    
    rightSwipe = [self createSwipeToAdd:@"Swipe"];
    CGSize xySize = [rightSwipe.text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:largeFontSize]];
    
                //We need xySize.width*1.5 and xySize.height*2 because using just xySize.width and xySize.height cuts off the text--UITextView has padding built in.

    CGRect rect = CGRectMake((screenWidth - xySize.width-30), screenHeight-240, xySize.width*1.5, xySize.height*2);
    rightSwipe.frame = rect;
    
                //Display it.
    
    [self.view addSubview:rightSwipe];
}

-(void)addSwipeForPreviousView {
    
                //Create "swipe" message to be shown with second haiku and set its location.
    
    leftSwipe = [self createSwipeToAdd:@"Swipe"];
    CGSize xySize = [leftSwipe.text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:largeFontSize]];
    
                //We need xySize.width*1.5 and xySize.height*2 because using just xySize.width and xySize.height cuts off the text--UITextView has padding built in.
    
    CGRect rect = CGRectMake(10, screenHeight-240, xySize.width*1.5, xySize.height*2);
    leftSwipe.frame = rect;
    
                //Display it
    
    [self.view addSubview:leftSwipe];
}

#pragma mark NAVIGATION METHODS

-(void)goToNextHaiku {
    
                //Increase the index by one.
    
    self.ghhaiku.newIndex++;
    
                //Set boolean for direction of animation.
    
    comingFromPrevious=NO;
    
                //Show next haiku in array
    
    [self displayHaiku];
    
                //Show swipe instructions if appropriate and adjust booleans accordingly
    
    if (leftSwipeSeen==NO) {
        [self addSwipeForPreviousView];
        leftSwipeSeen=YES;
    }
    else {
        [leftSwipe removeFromSuperview];
    }
}

-(void)goToPreviousHaiku {
    
                //Reduce the index by one, if it can be so reduced.
    
    if (!self.ghhaiku.newIndex<1)
    {
        self.ghhaiku.newIndex--;
        
                //Set boolean for direction of animation
        
        comingFromPrevious=YES;
        
                //Display the haiku.
        
        [self displayHaiku];
    }
}

#pragma mark ADDITION/DELETION METHODS

-(void)editHaiku {
    
                //Indicate we're in editing mode and go to the compose screen.
    
    self.ghhaiku.userIsEditing=YES;
    [self.tabBarController setSelectedIndex:1];
}

-(void)deleteHaiku {
    
                //Delete the haiku from the array of haiku.
    
    [self.ghhaiku.gayHaiku removeObjectAtIndex:self.ghhaiku.newIndex];
    
                //Clear the screen
    
    [displayHaikuTextView removeFromSuperview];
    [navBar removeFromSuperview];
    
                //Save the new set of user haiku, now missing the deleted haiku, to the docs folder.
    
    NSString *cat=@"user";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", cat];
    for (int i=0; i<[self.ghhaiku.gayHaiku filteredArrayUsingPredicate:predicate].count; i++)
    {
        id haikuToDelete = [[self.ghhaiku.gayHaiku filteredArrayUsingPredicate:predicate] objectAtIndex:i];
        NSString *haikuString = [haikuToDelete valueForKey:@"haiku"];
        if ([haikuString isEqualToString:displayHaikuTextView.text])
        {
            [self.ghhaiku.gayHaiku removeObjectIdenticalTo:[self.ghhaiku.gayHaiku objectAtIndex:i]];
            [self.ghhaiku saveToDocsFolder:@"userHaiku.plist"];
            break;
        }
    }
    [self.ghhaiku saveToDocsFolder:@"userHaiku.plist"];
    
                //Display next haiku so the screen won't be blank.
    
    [self displayHaiku];
}

#pragma mark SHARING METHODS

-(void)actionSheet:(UIActionSheet *)actSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
                //Take user to email, Facebook, or Twitter, depending on which option s/he's selected in the action sheet.
    
    {
        if (buttonIndex == 0)
        {
            [self openMail];
        }
        else if (buttonIndex == 1)
        {
            [self faceBook];
        }
        else if (buttonIndex == 2)
        {
            [self twit];
        }
    }
}

-(void)openMail {
    
                //Open Mail program and create email with haiku attached as image.
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:[NSString stringWithFormat:@"%@ has sent you a gay haiku.", [[UIDevice currentDevice] name]]];
        UIImage *myImage = [self createImage];
        NSData *imageData = UIImagePNGRepresentation(myImage);
        [mailer addAttachmentData:imageData mimeType:@"image/jpg" fileName:@"Gay Haiku http://gayhaiku.com"];
        NSString *emailBody = @"I thought you might like this gay haiku from the Gay Haiku iPhone app. Please love me?";
        [mailer setMessageBody:emailBody isHTML:NO];
        [self presentViewController:mailer animated:YES completion:NULL];
    }
    
                //Unless it's not possible to do so, in which case show an alert message.
    
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:@"I'm sorry." message:@"Your device doesn't seem to be able to email this haiku. Perhaps you'd like to tweet it or post it on Facebook instead?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)twit {
    
                //Set share mode to tweet and share the haiku.
    
    serviceType=SLServiceTypeTwitter;
    [self share];
}

-(void)faceBook {
    
                //Set share mode to Facebook and share the haiku.
    
    serviceType=SLServiceTypeFacebook;
    [self share];
}

-(void)share {
    
                //Send the haiku if it can be sent.
    
    if ([SLComposeViewController isAvailableForServiceType:serviceType])
    {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            
                //Create an alert message and show it in case of success.
            
            if (result != SLComposeViewControllerResultCancelled)
            {
                NSString *yesItSent;
                if (serviceType==SLServiceTypeTwitter)
                {
                    yesItSent = @"Tweet twitted.";
                }
                else if (serviceType==SLServiceTypeFacebook)
                {
                    yesItSent = @"Haiku posted.";
                }
                alert = [[UIAlertView alloc] initWithTitle:yesItSent message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        controller.completionHandler = myBlock;
        NSString *msgText;
        
                //Add line breaks to haiku in case of tweet.
        
        if (serviceType==SLServiceTypeTwitter)
        {
            NSString *stringWithoutLineBreaks = self.ghhaiku.text;
            if([stringWithoutLineBreaks rangeOfString:@"\\n"].location != NSNotFound) {
                //Check to make sure this actually does add line breaks in Twitter posting.
                msgText = [stringWithoutLineBreaks stringByReplacingOccurrencesOfString:@"\\n" withString:@"<br/>"];
            }
            else msgText=self.ghhaiku.text;
        }
        
                //Or just a regular Facebook message.
        
        else if (serviceType==SLServiceTypeFacebook)
        {
            msgText = @"Here is a gay haiku. Please love me?";
        }
        [controller setInitialText:msgText];
        [controller addURL:[NSURL URLWithString:@"http://www.gayhaiku.com"]];
        
                //Create the image.
        
        UIImage *img = [self createImage];
        UIImage *pic;
        
                //Scale the image if it's for Facebook.
        
        if (serviceType==SLServiceTypeFacebook)
        {
            pic = [self scaleImage:img];
        }
        else if (serviceType==SLServiceTypeTwitter)
        {
            pic = img;
        }
        [controller addImage:pic];
        
                //Post/tweet. You're done.
        
        [self presentViewController:controller animated:YES completion:Nil];
    }
    
                //Show an error alert message if there are login problems.
    
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:@"I'm sorry." message:@"I seem to be having trouble logging in. Would you mind checking your iPhone settings or trying again later?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(UIImage *)createImage {
    
                //Get ride of the "swipe" texts.
    
    if (rightSwipe)
    {
        [rightSwipe removeFromSuperview];
    }
    if (leftSwipe)
    {
        [leftSwipe removeFromSuperview];
    }
    
                //Take a picture of the screen.
    
    CGRect newRect = CGRectMake(0, 0, screenWidth, screenHeight-toolbarHeight);
    UIGraphicsBeginImageContext(newRect.size);
    [[self.view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    /*UIGraphicsBeginImageContext(self.view.bounds.size);
    [myImage drawInRect:CGRectMake(0, 0, screenWidth, screenHeight-toolbarHeight)];
    myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();*/
    
                //Return that picture.
    
    return myImage;
}

- (UIImage*) scaleImage:(UIImage*)image {
    
                //Scale the image so it will fit on a Facebook wall (height 350 pixels).

    CGSize scaledSize;
    scaledSize.height = 350;
    scaledSize.width = ((350*screenWidth)/screenHeight);
    UIGraphicsBeginImageContextWithOptions(scaledSize, NO, 0.975 );
    CGRect scaledImageRect = CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height);
    [image drawInRect:scaledImageRect];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)showMessage {
    
                //Offer user the choice to email, post on Facebook, or tweet.
    
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email",@"Facebook",@"Twitter", nil];
    if (navBar)
    {
        [navBar removeFromSuperview];
    }
    [actSheet showFromTabBar:self.tabBarController.tabBar];
}

@end