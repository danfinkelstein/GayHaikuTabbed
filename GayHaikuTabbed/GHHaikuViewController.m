//
//  GHHaikuViewController.m
//  Gay Haiku
//
//  Created by Joel Derfner on 12/2/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
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

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@interface GHHaikuViewController ()<UITextViewDelegate,MFMailComposeViewControllerDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate, UITabBarControllerDelegate>

@end

@implementation GHHaikuViewController

@synthesize ghhaiku;

-(void)viewDidLoad
{
	[super viewDidLoad];
        
    //Create and add gesture recognizers
    
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
    
    //load array of haiku and set index to 0
    
    if (!self.ghhaiku)
    {
        self.ghhaiku = [GHHaiku sharedInstance];
    }
    [self.ghhaiku loadHaiku];
    if (!self.ghhaiku.newIndex) self.ghhaiku.newIndex=0;

    //Add Parse
    
    [Parse setApplicationId:@"M7vcXO7ccmhNUbnLhmfnnmV8ezLvvuMvHwNZXrs8"
                  clientKey:@"Aw8j7MhJwsHxW1FxoHKuXojNGvrPSjDkACs7egRi"];
    
    //set up tab bar
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:.75]];
    
    self.tabBarController.delegate=self;
    
    //indicate that "swipe" for previous/next have not been seen yet this session
    
    swipeNextInstructionsSeen=NO;
    swipePreviousInstructionsSeen=NO;
    
    //display a haiku and show (and fade) the nav bar
    
    [self displayHaiku];
    [self showNavBarOnTap];
}

-(UITextView *)createSwipeToAdd {
    
    //Create "Swipe" text and its characteristics
    
    NSString *text = @"Swipe";
    UITextView *instructions = [[UITextView alloc] init];
    instructions.editable=NO;
    //Why doesn't this work?  [UIColor colorWithRed:123 green:47 blue:85 alpha:.75]; Replaced it with next line and changing text color to purple.
    instructions.textColor = [UIColor purpleColor];
    instructions.backgroundColor = [UIColor clearColor];
    instructions.text = text;
    instructions.font = [UIFont fontWithName:@"Zapfino" size:14];
    return instructions;
}

-(void)addSwipeForNextView
{
    
    //Create "swipe" message and set its location
    
    nextInstructions = [self createSwipeToAdd];
    CGSize dimensions = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 400);
    
    //Why did I choose 400?
    
    CGSize xySize = [nextInstructions.text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:14] constrainedToSize:dimensions lineBreakMode:0];
    CGRect rect = CGRectMake((dimensions.width - xySize.width-30), 240, xySize.width*1.5, (xySize.height*2));
    nextInstructions.frame = rect;
    
    //Display it.
    
    [self.view addSubview:nextInstructions];
}

-(void)addSwipeForPreviousView
{
    
    //Create "swipe" message and set its location.
    
    previousInstructions = [self createSwipeToAdd];
    CGSize dimensions = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 400);
    
    //Why did I choose 400?
    
    CGSize xySize = [nextInstructions.text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:14] constrainedToSize:dimensions lineBreakMode:0];
    CGRect rect = CGRectMake(10, 240, xySize.width*1.5, (xySize.height*2));
    previousInstructions.frame = rect;
    
    //Display it
    
    [self.view addSubview:previousInstructions];
}

- (void)viewWillAppear:(BOOL)animated

    //When the user returns from the compose screen having just composed a new haiku, this replaces whatever haiku was showing with the new user haiku.
{
    if (self.ghhaiku.justComposed==YES)
    {
        [super viewWillAppear:animated];
        [self displayHaiku];
        [self showNavBarOnTap];
        self.ghhaiku.justComposed=NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)displayHaiku
{
    //reset screen
    
    [displayHaikuTextView removeFromSuperview];
    
    //Produce self.ghhaiku.text as the new haiku.
    
    self.ghhaiku=[GHHaiku sharedInstance];
    [self.ghhaiku haikuToShow];
    
    //set CGSize
    
    CGSize dimensions = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 400); //Why did I choose 400?
    CGSize xySize = [self.ghhaiku.text sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:14] constrainedToSize:dimensions lineBreakMode:0];
    
    //set UITextView and its characteristics
    
    displayHaikuTextView = [[UITextView alloc] init];
    displayHaikuTextView.backgroundColor = [UIColor clearColor];
    displayHaikuTextView.editable=NO;
    displayHaikuTextView.font=[UIFont fontWithName:@"Helvetica Neue" size:14];
    displayHaikuTextView.text=self.ghhaiku.text;
    [displayHaikuTextView setFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width/2)-(xySize.width/2),[[UIScreen mainScreen] bounds].size.height/3,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height/3)];
    
    //set animation
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    if (comingFromPrevious==NO)
    {
        transition.subtype =kCATransitionFromRight;
    }
    else
    {
        transition.subtype=kCATransitionFromLeft;
    }
    transition.delegate = self;
    
    [displayHaikuTextView.layer addAnimation:transition forKey:nil];
    displayHaikuTextView.editable=NO;
    
    //Add text to view
    
    [self.view addSubview:displayHaikuTextView];
    
    //Remove navBar from view, just in case delete/edit version has been showing for user-generated haiku, so that user can't accidentally delete or edit default haiku.

    [navBar removeFromSuperview];
    
    //Show swipe for next/swipe for previous instructions if appropriate
    
    if (swipeNextInstructionsSeen==NO)
    {
        [self addSwipeForNextView];
        swipeNextInstructionsSeen=YES;
    }
    else
    {
        [nextInstructions removeFromSuperview];
    }
    if (swipePreviousInstructionsSeen==YES)
    {
        [previousInstructions removeFromSuperview];
    }
}

-(void)goToNextHaiku
{
    
    //Show next haiku in array
    
    [displayHaikuTextView removeFromSuperview];
    self.ghhaiku.newIndex++;
    comingFromPrevious=NO;
    [self displayHaiku];
    
    //Show swipe instructions if appropriate
    
    if (swipePreviousInstructionsSeen==NO)
    {
        [self addSwipeForPreviousView];
        swipePreviousInstructionsSeen=YES;
    }
    else
    {
        [previousInstructions removeFromSuperview];
    }
}

-(void)goToPreviousHaiku
{
    //Show previous haiku in array
    
    if (!self.ghhaiku.newIndex<1)
    {
        [displayHaikuTextView removeFromSuperview];
        self.ghhaiku.newIndex--;
        comingFromPrevious=YES;
        swipePreviousInstructionsSeen=YES;
        [self displayHaiku];
    }
}

-(void)showNavBarOnTap
{
    if (navBar)
    {
        [navBar removeFromSuperview];
    }
    //Create UINavigationBar.  The reason this isn't lazily instantiated is to remove the glitch whereby, if the user has tapped a user haiku and shown the trash/edit buttons in the nav bar, the next non-user haiku tapped shows those buttons momentarily before they disappear.
        
    navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44)];
    [navBar setTintColor:[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:.75]];
    navBar.translucent=YES;
    navBar.alpha = 0.75;
    
    //Create UINavigationItem

    titleBar = [[UINavigationItem alloc] init];
    
    //Add share button and, if appropriate, delete and edit buttons
        
    [self addShareButton];
    if (self.ghhaiku.isUserHaiku==YES)
    {
        [self addLeftButtons];
    }

    //Add navigation bar to screen.
        
    [navBar pushNavigationItem:titleBar animated:YES];
    [self.view addSubview:navBar];
        
    //Fade navigation bar:  first delay, so that buttons are pressable, then fade.
        
    double delayInSeconds = 3.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:.5
                             animations:^{
                                 navBar.alpha = 0;
                             }];
    });
}

-(void)addShareButton
{
    //Add a button allowing the user to share the haiku via Facebook, Twitter, or email.
    
    UIBarButtonItem *send = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:NSSelectorFromString(@"showMessage")];
    send.style=UIBarButtonItemStyleBordered;
    titleBar.rightBarButtonItem = send;
}

-(void)addLeftButtons

{
    //Add buttons allowing the user to delete and/or edit haiku s/he's composed.
    
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:NSSelectorFromString(@"deleteHaiku")];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:NSSelectorFromString(@"editHaiku")];
    NSArray *leftItems = [[NSArray alloc] initWithObjects:editButton, deleteButton, nil];
    titleBar.leftBarButtonItems = leftItems;
}

-(void)editHaiku
{
    self.ghhaiku.userIsEditing=YES;
    [self.tabBarController setSelectedIndex:1];
}

-(void)deleteHaiku
{
    
    //Delete the haiku
    
    [self.ghhaiku.gayHaiku removeObjectAtIndex:self.ghhaiku.newIndex];
    [displayHaikuTextView removeFromSuperview];
    [navBar removeFromSuperview];

    //Save the new set of user haiku to the docs folder.
    
    NSString *cat=@"user";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", cat];
    for (int i=0; i<[self.ghhaiku.gayHaiku filteredArrayUsingPredicate:predicate].count; i++)
    {
        if ([[[[self.ghhaiku.gayHaiku filteredArrayUsingPredicate:predicate] objectAtIndex:i] valueForKey:@"quote"] isEqualToString:displayHaikuTextView.text])
        {
            [self.ghhaiku.gayHaiku removeObjectIdenticalTo:[self.ghhaiku.gayHaiku objectAtIndex:i]];
            [self.ghhaiku saveToDocsFolder:@"userHaiku.plist"];
            break;
        }
    }
    [self.ghhaiku saveToDocsFolder:@"userHaiku.plist"];
    
    //Display haiku so the screen won't be blank.
    
    [self displayHaiku];
    
}

-(void)actionSheet:(UIActionSheet *)actSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
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

-(void)openMail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:[NSString stringWithFormat:@"%@ has sent you a gay haiku.", [[UIDevice currentDevice] name]]];
        UIImage *myImage = [self createImage];
        NSData *imageData = UIImagePNGRepresentation(myImage);
        [mailer addAttachmentData:imageData mimeType:@"image/jpg" fileName:@"blah"];
        NSString *emailBody = @"I thought you might like this gay haiku from the Gay Haiku iPhone app.  Please love me?";
        [mailer setMessageBody:emailBody isHTML:NO];
        [self presentViewController:mailer animated:YES completion:NULL];
    }
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:@"I'm sorry." message:@"Your device doesn't seem to be able to email this haiku.  Perhaps you'd like to tweet it or post it on Facebook instead?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)twit
{
    serviceType=SLServiceTypeTwitter;
    [self share];
}

-(void)faceBook
{
    serviceType=SLServiceTypeFacebook;
    [self share];
}

-(void)share
{
    if ([SLComposeViewController isAvailableForServiceType:serviceType])
    {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            
            if (result == SLComposeViewControllerResultCancelled)
            {
                NSLog(@"Cancelled");
            }
            else
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
        if (serviceType==SLServiceTypeTwitter)
        {
            msgText = self.ghhaiku.text;
        }
        else if (serviceType==SLServiceTypeFacebook)
        {
            msgText = @"Here is a gay haiku.  Please love me?";
        }
        [controller setInitialText:msgText];
        [controller addURL:[NSURL URLWithString:@"http://www.gayhaiku.com"]];
        UIImage *img = [self createImage];
        UIImage *pic;
        if (serviceType==SLServiceTypeFacebook)
        {
            pic = [self scaleImage:img];
        }
        else if (serviceType==SLServiceTypeTwitter)
        {
            pic = img;
        }
        [controller addImage:pic];
        [self presentViewController:controller animated:YES completion:Nil];
    }
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:@"I'm sorry." message:@"I seem to be having trouble logging in.  Would you mind checking your iPhone settings or trying again later?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(UIImage *)createImage
{
    if (nextInstructions)
    {
        [nextInstructions removeFromSuperview];
    }
    if (previousInstructions)
    {
        [previousInstructions removeFromSuperview];
    }
    CGRect newRect = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-44);
    UIGraphicsBeginImageContext(newRect.size); //([self.view frame].size])
    [[self.view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIGraphicsBeginImageContext([self.view bounds].size);
    [myImage drawInRect:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-44)];
    myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return myImage;
}

- (UIImage*) scaleImage:(UIImage*)image
{
    
//Check to make sure this is right.  Then clean it up.
    int widthToUse = [[UIScreen mainScreen] bounds].size.width;
    int heightToUse = [[UIScreen mainScreen] bounds].size.height;
    CGSize scaledSize;
    scaledSize.height = 350;
    scaledSize.width = ((350*widthToUse)/heightToUse);
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.975 );
    CGRect scaledImageRect = CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height);
    [image drawInRect:scaledImageRect];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)showMessage
{
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email",@"Facebook",@"Twitter", nil];
    if (navBar)
    {
        [navBar removeFromSuperview];
    }
    //actSheet.tag=2;
    [actSheet showFromTabBar:self.tabBarController.tabBar];
}

@end
