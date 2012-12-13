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
#import "UIImage+ProportionalFill.h"

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@interface GHHaikuViewController ()<UITextViewDelegate,MFMailComposeViewControllerDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate, UITabBarControllerDelegate>

@end

@implementation GHHaikuViewController

@synthesize ghhaiku;
@synthesize displayHaikuTextView, serviceType;
@synthesize alert, navBar, nextInstructions, previousInstructions, swipeNextInstructionsSeen, swipePreviousInstructionsSeen, actionMenuShowing;

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
    
    //load arrays of haiku
    
    if (!self.ghhaiku)
    {
        self.ghhaiku = [GHHaiku sharedInstance];
    }
    [self.ghhaiku loadHaiku];

    //Add Parse
    
    [Parse setApplicationId:@"M7vcXO7ccmhNUbnLhmfnnmV8ezLvvuMvHwNZXrs8"
                  clientKey:@"Aw8j7MhJwsHxW1FxoHKuXojNGvrPSjDkACs7egRi"];
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:.75]];
    self.actionMenuShowing=NO;
    
    self.tabBarController.delegate=self;
    self.swipeNextInstructionsSeen=NO;
    self.swipePreviousInstructionsSeen=NO;
    
    [self goToNextHaiku];

    [self showNavBarOnTap];
}

-(void)addSwipeForNextView
{
    NSString *text = @"Swipe for next haiku.";
    CGSize dimensions = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 400); //Why did I choose 400?
    CGSize xySize = [text sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:14] constrainedToSize:dimensions lineBreakMode:0];
    CGRect rect = CGRectMake((dimensions.width - xySize.width-10), 240, xySize.width, (xySize.height*2));
    self.nextInstructions = [[UITextView alloc] initWithFrame:(rect)];
    self.nextInstructions.editable=NO;
//Why doesn't this work?  [UIColor colorWithRed:123 green:47 blue:85 alpha:.75]; Replaced it with next line and changing text color to purple.
    self.nextInstructions.backgroundColor = [UIColor clearColor];
    self.nextInstructions.text = text;
    self.nextInstructions.textColor = [UIColor purpleColor];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromLeft;
    transition.delegate = self;
    
    [self.view addSubview:self.nextInstructions];
}

-(void)addSwipeForPreviousView
{
    NSString *text = @"Swipe for previous haiku.";
    CGSize dimensions = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 400); //Why did I choose 400?
    CGSize xySize = [text sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:14] constrainedToSize:dimensions lineBreakMode:0];
    CGRect rect = CGRectMake(10, 240, xySize.width, (xySize.height*2));
    self.previousInstructions = [[UITextView alloc] initWithFrame:(rect)];
    self.previousInstructions.editable=NO;
//Why doesn't this work?  [UIColor colorWithRed:123 green:47 blue:85 alpha:.75]; Replaced it with next line and changing text color to purple.
    self.previousInstructions.backgroundColor = [UIColor clearColor];
    self.previousInstructions.text = text;
    self.previousInstructions.textColor = [UIColor purpleColor];
    
    [self.view addSubview:self.previousInstructions];
}

- (void) viewWillAppear:(BOOL)animated
{
    if (self.ghhaiku.justComposed==YES)
    {
        NSLog(@"Just composed.");
        [super viewWillAppear:animated];
        self.displayHaikuTextView.text = [[self.ghhaiku.gayHaiku lastObject] valueForKey:@"quote"];
        self.ghhaiku.justComposed=NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)goToNextHaiku
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"swipeForNextSeen?"])
    {
        self.swipeNextInstructionsSeen = YES;
        [self nextInstructions];
        [defaults setBool:self.swipeNextInstructionsSeen forKey:@"swipeForNextSeen?"];
        [defaults synchronize];
        [self addSwipeForNextView];
    }
    
    //reset screen, saved text, composed text, segment controller
    
    self.displayHaikuTextView.text=@"";
    
    //select haiku at random
    
    NSString *textForNextHaiku = [self.ghhaiku haikuToShow]; //try making this self.displayHaikuTextView.text (and changing rest of method to match) and seeing what happens?
    
    //set CGSize
    
    CGSize dimensions = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 400); //Why did I choose 400?
    CGSize xySize = [textForNextHaiku sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:14] constrainedToSize:dimensions lineBreakMode:0];
    
    //set UITextView
    
    self.displayHaikuTextView = [[UITextView alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width/2)-(xySize.width/2),[[UIScreen mainScreen] bounds].size.height/3,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height/3)];
    self.displayHaikuTextView.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
    self.displayHaikuTextView.backgroundColor = [UIColor clearColor];
    self.displayHaikuTextView.text=textForNextHaiku;
    
    //set animation
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromRight;
    transition.delegate = self;
    
    //set view
    
    [self.displayHaikuTextView.layer addAnimation:transition forKey:nil];
    self.displayHaikuTextView.editable=NO;
    [self.view addSubview:self.displayHaikuTextView];
    
    if (self.swipeNextInstructionsSeen==YES)
    {
        [self.nextInstructions removeFromSuperview];
    }
    else
    {
        [self addSwipeForNextView];
        self.swipeNextInstructionsSeen=YES;
    }
    if (self.swipePreviousInstructionsSeen==YES)
    {
        [self.previousInstructions removeFromSuperview];
    }
    else if (self.ghhaiku.arrayOfSeen.count!=1)
    {
        [self addSwipeForPreviousView];
        self.swipePreviousInstructionsSeen=YES;
    }
}

-(void)goToPreviousHaiku
{
    if (self.ghhaiku.arrayOfSeen.count>1 && self.ghhaiku.index>1)
    {
        //reset screen, saved text, composed text, segment controller
        self.displayHaikuTextView.text=@"";
    
        //adjust index
        self.ghhaiku.index -= 1;
        
        if ([[[self.ghhaiku.arrayOfSeen objectAtIndex:self.ghhaiku.index-1] valueForKey:@"category"] isEqualToString:@"user"])
        {
            self.ghhaiku.isUserHaiku=YES;
        }
        
        //set haiku
        NSString *textForPreviousHaiku = [[self.ghhaiku.arrayOfSeen objectAtIndex:self.ghhaiku.index-1] valueForKey:@"quote"]; //replace textForNextHaiku with self.displayHaikuTextView and see what happens
    
        //set CGSize
    
        CGSize dimensions = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 400); //Why did I choose 400?
        CGSize xySize = [textForPreviousHaiku sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:14] constrainedToSize:dimensions lineBreakMode:0];
    
        //set UITextView
    
        self.displayHaikuTextView = [[UITextView alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width/2)-(xySize.width/2),[[UIScreen mainScreen] bounds].size.height/3,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height/3)];
        self.displayHaikuTextView.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        self.displayHaikuTextView.backgroundColor = [UIColor clearColor];
        self.displayHaikuTextView.text=textForPreviousHaiku;
    
        //set animation
        CATransition *transition = [CATransition animation];
        transition.duration = 0.25;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype =kCATransitionFromLeft;
        transition.delegate = self;
            
        //set view
        
        [self.navBar removeFromSuperview];
        [self.displayHaikuTextView.layer addAnimation:transition forKey:nil];
        self.displayHaikuTextView.editable=NO;
        [self.view addSubview:self.displayHaikuTextView];
        
        if (self.swipePreviousInstructionsSeen==YES)
        {
            [self.previousInstructions removeFromSuperview];
        }
    }
}

-(void)showNavBarOnTap
{
    if (self.actionMenuShowing==NO)
    {
        
        //Create UINavigationBar.  The reason this isn't lazily instantiated is to remove the glitch whereby, if the user has tapped a user haiku and shown the trash/edit buttons in the nav bar, the next non-user haiku tapped shows those buttons momentarily before they disappear. 
        
        self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44)];
        [self.navBar setTintColor:[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:.75]];
        self.navBar.alpha = 0.75;
        self.navBar.translucent=YES;
        
        //Create the UINavigationItem.
    
        self.titleBar = [[UINavigationItem alloc] init];
        self.titleBar.hidesBackButton=YES;
        
        //Add share button and, if appropriate, delete and edit buttons
        
        [self addShareButton];
        if (self.ghhaiku.isUserHaiku==YES)
        {
            [self addLeftButtons];
        }

        //Add navigation bar to screen.
        
        [self.navBar pushNavigationItem:self.titleBar animated:YES];
        [self.view addSubview:self.navBar];
        
        //Fade navigation bar:  first delay, so that buttons are pressable, then fade.
        
        double delayInSeconds = 4.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:.5
                             animations:^{
                                 self.navBar.alpha = 0;
                             }];
        });

    }
    else [self.navBar removeFromSuperview];
}

-(void)addShareButton
{
    
    //Add a button allowing the user to share the haiku via Facebook, Twitter, or email.
    
    UIBarButtonItem *send = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:NSSelectorFromString(@"showMessage")];
    send.style=UIBarButtonItemStyleBordered;
    self.titleBar.rightBarButtonItem = send;
}

-(void)addLeftButtons

//No method "editHaiku" exists yet.

{
    //Add buttons allowing the user to delete and/or edit haiku s/he's composed.
    
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:NSSelectorFromString(@"deleteHaiku")];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:NSSelectorFromString(@"editHaiku")];
    UIImage *edit = [UIImage imageNamed:@"187-pencil.png"];
    editButton.image=edit;
    NSArray *leftItems = [[NSArray alloc] initWithObjects:editButton, deleteButton, nil];
    self.titleBar.leftBarButtonItems = leftItems;
}

-(void)deleteHaiku
{
    NSLog(@"number of haiku:  %d",self.ghhaiku.gayHaiku.count);
    
    //Replace each haiku with the one just ahead of it in the gayHaiku array so that there are no blank spaces.
    
    for (int i=0; i<self.ghhaiku.gayHaiku.count; i++)
    {
        if ([[[self.ghhaiku.gayHaiku objectAtIndex:i] valueForKey:@"quote"] isEqualToString:self.displayHaikuTextView.text])
        {
            [self.ghhaiku.gayHaiku removeObjectAtIndex:i];
            for (int j=i; j<self.ghhaiku.gayHaiku.count-1; j++)
            {
                [self.ghhaiku.gayHaiku insertObject:[self.ghhaiku.gayHaiku objectAtIndex:j+1] atIndex:j];
                [self.ghhaiku.gayHaiku removeObjectAtIndex:j+1];
            }
        }
    }
    for (int i=0; i<self.ghhaiku.gayHaiku.count; i++)
    {
        NSLog(@"index:  %d; haiku:  %@",i,[self.ghhaiku.gayHaiku objectAtIndex:i]);
    }
    
    //Remove the navigation bar so that the haiku that replaces the deleted haiku in self.displayHaikuTextView can't be deleted if it isn't a user haiku.
    
    [self.navBar removeFromSuperview];

    //Save the new set of user haiku to the docs folder.
    
    NSString *cat=@"user";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", cat];
    for (int i=0; i<[self.ghhaiku.gayHaiku filteredArrayUsingPredicate:predicate].count; i++)
    {
        if ([[[[self.ghhaiku.gayHaiku filteredArrayUsingPredicate:predicate] objectAtIndex:i] valueForKey:@"quote"] isEqualToString:self.displayHaikuTextView.text])
        {
            [self.ghhaiku.gayHaiku removeObjectIdenticalTo:[self.ghhaiku.gayHaiku objectAtIndex:i]];
            [self.ghhaiku saveToDocsFolder:@"userHaiku.plist"];
            break;
        }
    }
    [self.ghhaiku saveToDocsFolder:@"userHaiku.plist"];
    
    //Go to the next haiku so the screen won't be blank.
    
    [self goToNextHaiku];
    
    NSLog(@"number of haiku:  %d",self.ghhaiku.gayHaiku.count);
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
        self.alert = [[UIAlertView alloc] initWithTitle:@"I'm sorry." message:@"Your device doesn't seem to be able to email this haiku.  Perhaps you'd like to tweet it or post it on Facebook instead?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [self.alert show];
    }
}

-(void)twit
{
    self.serviceType=SLServiceTypeTwitter;
    [self share];
}

-(void)faceBook
{
    self.serviceType=SLServiceTypeFacebook;
    [self share];
}

-(void)share
{
    if ([SLComposeViewController isAvailableForServiceType:self.serviceType])
    {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:self.serviceType];
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            
            if (result == SLComposeViewControllerResultCancelled)
            {
                NSLog(@"Cancelled");
            }
            else
            {
                NSString *yesItSent;
                if (self.serviceType==SLServiceTypeTwitter)
                {
                    yesItSent = @"Tweet twitted.";
                }
                else if (self.serviceType==SLServiceTypeFacebook)
                {
                    yesItSent = @"Haiku posted.";
                }
                self.alert = [[UIAlertView alloc] initWithTitle:yesItSent message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [self.alert show];
            }
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        controller.completionHandler = myBlock;
        NSString *msgText;
        if (self.serviceType==SLServiceTypeTwitter)
        {
            msgText = @"A gay haiku for your viewing pleasure.";
        }
        else if (self.serviceType==SLServiceTypeFacebook)
        {
            msgText = @"Here is a gay haiku.  Please love me?";
        }
        [controller setInitialText:msgText];
        [controller addURL:[NSURL URLWithString:@"http://www.gayhaiku.com"]];
        UIImage *img = [self createImage];
        UIImage *pic;
        if (self.serviceType==SLServiceTypeFacebook)
        {
            CGSize size = CGSizeMake((404*320)/([[UIScreen mainScreen] bounds].size.height - 64), 404);
            pic = [img imageScaledToFitSize:size];
        }
        else if (self.serviceType==SLServiceTypeTwitter)
        {
            pic = img;
        }
        [controller addImage:pic];
        [self presentViewController:controller animated:YES completion:Nil];
    }
    else
    {
        self.alert = [[UIAlertView alloc] initWithTitle:@"I'm sorry." message:@"I seem to be having trouble logging in.  Would you mind checking your iPhone settings or trying again later?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [self.alert show];
    }
}

-(UIImage *)createImage
{
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
    CGSize scaledSize;
    scaledSize.height = 156;
    scaledSize.width = 120; 
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height);
    [image drawInRect:scaledImageRect];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)showMessage
{
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email",@"Facebook",@"Twitter", nil];
    if (self.navBar)
    {
        [self.navBar removeFromSuperview];
    }
    actSheet.tag=2;
    [actSheet showFromTabBar:self.tabBarController.tabBar];
}

@end
