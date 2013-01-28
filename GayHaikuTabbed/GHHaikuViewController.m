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
#import "GHVerify.h"


@interface GHHaikuViewController ()<UITextViewDelegate,MFMailComposeViewControllerDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) GHAppDefaults *userInfo;
@property (strong, nonatomic) UIColor *screenColorTrans;
@property (strong, nonatomic) UIAlertView *alert;
@property (strong, nonatomic) UINavigationBar *navBar;
@property (strong, nonatomic) UINavigationItem *titleBar;
@property (strong, nonatomic) UITextView *displayHaikuTextView;
@property (strong, nonatomic) UITextView *leftSwipe;
@property (strong, nonatomic) UITextView *rightSwipe;
@property (strong, nonatomic) NSString *serviceType;
@property (nonatomic) int textWidth;
@property (nonatomic) BOOL comingFromPrevious;
@property (nonatomic) BOOL rightSwipeSeen;
@property (nonatomic) BOOL leftSwipeSeen;

@end

@implementation GHHaikuViewController

@synthesize ghhaiku;

#pragma mark CREATION/SETUP METHODS

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *background;
    background.backgroundColor = [UIColor whiteColor];
    self.screenColorTrans = [UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:.75];
    self.view.autoresizesSubviews=YES;
    [self.view addSubview:background];
    screenHeight = self.view.bounds.size.height;
    screenWidth = self.view.bounds.size.width;
    
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
    
    [[UITabBar appearance] setTintColor:self.screenColorTrans];
    self.tabBarController.delegate=self;
    
                //Indicate that "swipe" text for previous/next have not been seen yet this session
    
    _rightSwipeSeen=NO;
    _leftSwipeSeen=NO;
    
                //Display first haiku and show (and fade) the nav bar
    
    [self displayHaiku];
    [self showNavBarOnTap];
    self.userInfo = [GHAppDefaults sharedInstance];
    
}

-(UITextView *)createSwipeToAdd {
    
                //Create "Swipe" text and its characteristics
    
    UITextView *instructions = [[UITextView alloc] init];
    instructions.editable=NO;
    instructions.userInteractionEnabled=NO;
    UIColor *screenColorOp = [UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:1];
    instructions.textColor = screenColorOp;
    instructions.backgroundColor = [UIColor clearColor];
    instructions.text = @"Swipe";
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
    
    if (_navBar) {
        [_navBar removeFromSuperview];
    }
    
                //Create UINavigationBar. The reason this isn't lazily instantiated is to remove the glitch whereby, if the user has tapped a user haiku and shown the trash/edit buttons in the nav bar, the next non-user haiku tapped shows those buttons momentarily before they disappear.
    
    _navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, toolbarHeight)];
    [_navBar setTintColor:self.screenColorTrans];
    _navBar.translucent=YES;
    
                //Create UINavigationItem
    
    _titleBar = [[UINavigationItem alloc] init];
    
                //Add share button and, if appropriate, delete and edit buttons
    
    [self addShareButton];
    if (self.ghhaiku.isUserHaiku==YES) {
        [self addLeftButtons];
    }
    
                //Add navigation bar to screen.
    
        [_navBar pushNavigationItem:_titleBar animated:YES];
        [self.view addSubview:_navBar];
    
                //Fade navigation bar: first delay, so that buttons are pressable, then fade.
    
    double delayInSeconds = 3.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:.5
                         animations:^{
                             _navBar.alpha = 0;
                         }];
    });
}

-(void)addShareButton {
    
                //Add a button allowing the user to share the haiku via Facebook, Twitter, or email.
    
    UIBarButtonItem *send = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showMessage)];
    send.style=UIBarButtonItemStyleBordered;
    _titleBar.rightBarButtonItem = send;
}

-(void)addLeftButtons {
    
                //Add buttons allowing the user to delete and/or edit haiku s/he's composed.
    
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteHaiku)];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editHaiku)];
    NSArray *leftItems = [[NSArray alloc] initWithObjects:editButton, deleteButton, nil];
    _titleBar.leftBarButtonItems = leftItems;
}

#pragma mark DISPLAY METHODS

-(void)measureWidthOfTextView {
    GHVerify *verify = [[GHVerify alloc] init];
    float widthOfLongestLineSoFar = 0.0;
    NSArray *lines = [verify splitHaikuIntoLines:self.ghhaiku.text];
    for (int i = 0; i < lines.count; i++) {
        CGSize sizeOfLine = [verify.listOfLines[i] sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:mediumFontSize]];
        float widthOfLineUnderConsideration = sizeOfLine.width;
        if (widthOfLongestLineSoFar<widthOfLineUnderConsideration) {
            widthOfLongestLineSoFar = widthOfLineUnderConsideration;
        }
    }
    self.textWidth = widthOfLongestLineSoFar;
}

-(void)displayHaiku {
    
                //Empty screen
    
    [self.displayHaikuTextView removeFromSuperview];
    
                //Produce self.ghhaiku.text as the new haiku.
    
    self.ghhaiku=[GHHaiku sharedInstance];
    [self.ghhaiku haikuToShow];
    [self measureWidthOfTextView];

                    //Set CGSize so that haiku can be laid out in the center.
    
    CGSize dimensions = CGSizeMake(screenWidth, screenHeight);
    CGSize xySize = [self.ghhaiku.text sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:mediumFontSize] constrainedToSize:dimensions lineBreakMode:0];

//If this is a problem, replace mediumFontSize in above line with largeFontSize.
    
    int textHeight = xySize.height+16;
    
                //Set UITextView and its characteristics
    
    self.displayHaikuTextView = [[UITextView alloc] init];
    self.displayHaikuTextView.backgroundColor = [UIColor clearColor];
    self.displayHaikuTextView.editable=NO;
    self.displayHaikuTextView.userInteractionEnabled=NO;
    self.displayHaikuTextView.font=[UIFont fontWithName:@"Helvetica Neue" size:mediumFontSize];
    self.displayHaikuTextView.text=self.ghhaiku.text;
    [self.displayHaikuTextView setFrame:CGRectMake((screenWidth/2)-(_textWidth/2),screenHeight/2-xySize.height,_textWidth/2 + screenWidth/2,textHeight*2)];
 
                //Set animation
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    
                //Set direction of animation depending on whether we're going to a previous or a next haiku.
    
    if (_comingFromPrevious==NO) {
        transition.subtype =kCATransitionFromRight;
    }
    else {
        transition.subtype=kCATransitionFromLeft;
    }
    transition.delegate = self;
    [self.displayHaikuTextView.layer addAnimation:transition forKey:nil];
    
                //Add text to view.
    
    [self.view addSubview:self.displayHaikuTextView];
    
                //Remove navBar from view, just in case delete/edit version has been showing for user-generated haiku, so that user can't accidentally delete or edit default haiku.
    
    [_navBar removeFromSuperview];
    
                //Show swipe for next/swipe for previous instructions if appropriate (and adjust booleans accordingly; remove them if appropriate.
    
    if (_rightSwipeSeen==NO) {
        [self addSwipeForNextView];
        _rightSwipeSeen=YES;
    }
    else {
        [_rightSwipe removeFromSuperview];
    }
    if (_leftSwipeSeen==YES) {
        [_leftSwipe removeFromSuperview];
    }
}

-(void)addSwipeForNextView {
    
                //Create "swipe" message to be shown with first haiku and set its location.
    
    _rightSwipe = [self createSwipeToAdd];
    CGSize xySize = [_rightSwipe.text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:largeFontSize]];
    
                //We need xySize.width*1.5 and xySize.height*2 because using just xySize.width and xySize.height cuts off the text--UITextView has padding built in.

    CGRect rect = CGRectMake((screenWidth - xySize.width-30), screenHeight-240, xySize.width*1.5, xySize.height*2);
    _rightSwipe.frame = rect;
    
                //Display it.
    
    [self.view addSubview:_rightSwipe];
}

-(void)addSwipeForPreviousView {
    
                //Create "swipe" message to be shown with second haiku and set its location.
    
    _leftSwipe = [self createSwipeToAdd];
    CGSize xySize = [_leftSwipe.text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:largeFontSize]];
    
                //We need xySize.width*1.5 and xySize.height*2 because using just xySize.width and xySize.height cuts off the text--UITextView has padding built in.
    
    CGRect rect = CGRectMake(10, screenHeight-240, xySize.width*1.5, xySize.height*2);
    _leftSwipe.frame = rect;
    
                //Display it
    
    [self.view addSubview:_leftSwipe];
}

#pragma mark NAVIGATION METHODS

-(void)goToNextHaiku {
    
                //Increase the index by one.
    
    self.ghhaiku.newIndex++;
    
                //Set boolean for direction of animation.
    
    _comingFromPrevious=NO;
    
                //Show next haiku in array
    
    [self displayHaiku];
    
                //Show swipe instructions if appropriate and adjust booleans accordingly
    
    if (_leftSwipeSeen==NO) {
        [self addSwipeForPreviousView];
        _leftSwipeSeen=YES;
    }
    else {
        [_leftSwipe removeFromSuperview];
    }
}

-(void)goToPreviousHaiku {
    
                //Reduce the index by one, if it can be so reduced.
    
    if (!self.ghhaiku.newIndex<1)
    {
        self.ghhaiku.newIndex--;
    }
    else {
        self.ghhaiku.newIndex = self.ghhaiku.gayHaiku.count-1;
    }
    
                //Set boolean for direction of animation
        
    _comingFromPrevious=YES;
        
                //Display the haiku.
        
    [self displayHaiku];
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
    
    [self.displayHaikuTextView removeFromSuperview];
    [_navBar removeFromSuperview];
    
                //Save the new set of user haiku, now missing the deleted haiku, to the docs folder.
    
    NSString *cat=@"user";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", cat];
    for (int i=0; i<[self.ghhaiku.gayHaiku filteredArrayUsingPredicate:predicate].count; i++)
    {
        NSArray *filtArr = [self.ghhaiku.gayHaiku filteredArrayUsingPredicate:predicate];
        id haikuToDelete = filtArr[i];
        NSString *haikuString = [haikuToDelete valueForKey:@"haiku"];
        if ([haikuString isEqualToString:self.displayHaikuTextView.text])
        {
            [self.ghhaiku.gayHaiku removeObjectIdenticalTo:self.ghhaiku.gayHaiku[i]];
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
        if (self.userInfo.author) {
            [mailer setSubject:[NSString stringWithFormat:@"%@ has sent you a gay haiku.", self.userInfo.author]];
        }
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
        self.alert = [[UIAlertView alloc] initWithTitle:@"I'm sorry." message:@"Your device doesn't seem to be able to email this haiku. Perhaps you'd like to tweet it or post it on Facebook instead?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [self.alert show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

-(void)twit {
    
                //Set share mode to tweet and share the haiku.
    
    _serviceType=SLServiceTypeTwitter;
    [self share];
}

-(void)faceBook {
    
                //Set share mode to Facebook and share the haiku.
    
    _serviceType=SLServiceTypeFacebook;
    [self share];
}

-(void)share {
    
                //Send the haiku if it can be sent.
    
    if ([SLComposeViewController isAvailableForServiceType:_serviceType])
    {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:_serviceType];
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            
                //Create an alert message and show it in case of success.
            
            if (result != SLComposeViewControllerResultCancelled)
            {
                NSString *yesItSent;
                if (_serviceType==SLServiceTypeTwitter)
                {
                    yesItSent = @"Tweet twitted.";
                }
                else if (_serviceType==SLServiceTypeFacebook)
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
        
                //Add line breaks to haiku in case of tweet.
        
        if (_serviceType==SLServiceTypeTwitter)
        {
            NSString *stringWithoutLineBreaks = self.ghhaiku.text;
            if([stringWithoutLineBreaks rangeOfString:@"\\n"].location != NSNotFound) {
                //Check to make sure this actually does add line breaks in Twitter posting.
                msgText = [stringWithoutLineBreaks stringByReplacingOccurrencesOfString:@"\\n" withString:@"<br/>"];
            }
            else msgText=self.ghhaiku.text;
        }
        
                //Or just a regular Facebook message.
        
        else if (_serviceType==SLServiceTypeFacebook)
        {
            msgText = @"Here is a gay haiku. Please love me?";
        }
        [controller setInitialText:msgText];
        [controller addURL:[NSURL URLWithString:@"http://www.gayhaiku.com"]];
        
                //Create the image.
        
        UIImage *img = [self createImage];
        UIImage *pic;
        
                //Scale the image if it's for Facebook.
        
        if (_serviceType==SLServiceTypeFacebook)
        {
            pic = [self scaleImage:img];
        }
        else if (_serviceType==SLServiceTypeTwitter)
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
        self.alert = [[UIAlertView alloc] initWithTitle:@"I'm sorry." message:@"I seem to be having trouble logging in. Would you mind checking your iPhone settings or trying again later?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [self.alert show];
    }
}

-(UIImage *)createImage {
    
                //Get ride of the "swipe" texts.
    
    if (_rightSwipe)
    {
        [_rightSwipe removeFromSuperview];
    }
    if (_leftSwipe)
    {
        [_leftSwipe removeFromSuperview];
    }
    
                //Take a picture of the screen.
    
    CGRect newRect = CGRectMake(0, 0, screenWidth, screenHeight-toolbarHeight);
    UIGraphicsBeginImageContext(newRect.size);
    [[self.view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
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
    if (_navBar)
    {
        [_navBar removeFromSuperview];
    }
    [actSheet showFromTabBar:self.tabBarController.tabBar];
}

@end