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
#import "DMActivityInstagram.h"

@interface GHHaikuViewController ()<UITextViewDelegate,MFMailComposeViewControllerDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate, UITabBarControllerDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) GHAppDefaults *userInfo;
@property (strong, nonatomic) UIAlertView *alert;
@property (strong, nonatomic) UINavigationBar *navBar;
@property (strong, nonatomic) UINavigationItem *titleBar;
@property (strong, nonatomic) UITextView *displayHaikuTextView;
@property (strong, nonatomic) UITextView *leftSwipe;
@property (strong, nonatomic) UITextView *rightSwipe;
@property (strong, nonatomic) NSString *serviceType;
@property (nonatomic) int textWidth;
@property (nonatomic) BOOL appIsComingFromPreviousHaiku;
@property (nonatomic) BOOL rightSwipeHasBeenSeen;
@property (nonatomic) BOOL leftSwipeHasBeenSeen;

@end

@implementation GHHaikuViewController

@synthesize ghhaiku;

#pragma mark CREATION/SETUP METHODS

-(void)viewDidLoad{
    [super viewDidLoad];
    UIImageView *background;
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
    self.userInfo = [GHAppDefaults sharedInstance];
    [self.userInfo setUserDefaults];
    
                //Add Parse
    
    [Parse setApplicationId:@"M7vcXO7ccmhNUbnLhmfnnmV8ezLvvuMvHwNZXrs8"
                  clientKey:@"Aw8j7MhJwsHxW1FxoHKuXojNGvrPSjDkACs7egRi"];
    
                //Set up tab bar
    
    [[UITabBar appearance] setTintColor:self.userInfo.screenColorTrans];
    self.tabBarController.delegate=self;
    
                //Indicate that "swipe" text for previous/next have not been seen yet this session
    
    self.rightSwipeHasBeenSeen=NO;
    self.leftSwipeHasBeenSeen=NO;
    
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
    instructions.textColor = self.userInfo.screenColorOp;
    instructions.backgroundColor = [UIColor clearColor];
    instructions.text = @"Swipe";
    instructions.font = [UIFont fontWithName:@"Zapfino" size:largeFontSize];
    return instructions;
}

- (void)viewWillAppear:(BOOL)animated {
    
                //When the user returns from the compose screen having just composed a new haiku, replace whatever haiku was showing before with the new user haiku.
    
    if (self.ghhaiku.justComposed==YES) {
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
    
    [self.navBar removeFromSuperview];
    
                //Create UINavigationBar. The reason this isn't lazily instantiated is to remove the glitch whereby, if the user has tapped a user haiku and shown the trash/edit buttons in the nav bar, the next non-user haiku tapped shows those buttons momentarily before they disappear.
    
    self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, toolbarHeight)];
    [self.navBar setTintColor:self.userInfo.screenColorTrans];
    self.navBar.translucent=YES;
    
                //Create UINavigationItem
    
    self.titleBar = [[UINavigationItem alloc] init];
    
                //Add share button and, if appropriate, delete and edit buttons
    
    [self addShareButton];
    if (self.ghhaiku.isUserHaiku==YES) {
        [self addLeftButtons];
    }
    
                //Add navigation bar to screen.
    
        [self.navBar pushNavigationItem:self.titleBar animated:YES];
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

-(void)addShareButton {
    
                //Add a button allowing the user to share the haiku via Facebook, Twitter, or email.
    
    UIBarButtonItem *send = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
    send.style=UIBarButtonItemStyleBordered;
    self.titleBar.rightBarButtonItem = send;
}

-(void)addLeftButtons {
    
                //Add buttons allowing the user to delete and/or edit haiku s/he's composed.
    
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteHaiku)];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editHaiku)];
    NSArray *leftItems = [[NSArray alloc] initWithObjects:editButton, deleteButton, nil];
    self.titleBar.leftBarButtonItems = leftItems;
}

#pragma mark DISPLAY METHODS

-(void)measureWidthOfTextView {
    GHVerify *verify = [[GHVerify alloc] init];
    float widthOfLongestLineSoFar = 0.0;
    NSArray *lines = [verify splitHaikuIntoLines:self.ghhaiku.text];
    for (int i = 0; i < lines.count; i++) {
        CGSize sizeOfLine = [verify.listOfLines[i] sizeWithFont:[UIFont fontWithName:@"Georgia" size:mediumFontSize]];
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
    CGSize xySize = [self.ghhaiku.text sizeWithFont:[UIFont fontWithName:@"Georgia" size:mediumFontSize] constrainedToSize:dimensions lineBreakMode:0];

//If this is a problem, replace mediumFontSize in above line with largeFontSize.
    
    int textHeight = xySize.height+16;
    
                //Set UITextView and its characteristics
    
    self.displayHaikuTextView = [self createTextViewForDisplay:self.ghhaiku.text];
    self.displayHaikuTextView.frame = CGRectMake((screenWidth/2)-(self.textWidth/2),screenHeight/2-xySize.height,self.textWidth/2 + screenWidth/2,textHeight*2);
 
                //Set animation
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    
                //Set direction of animation depending on whether we're going to a previous or a next haiku.
    
    if (self.appIsComingFromPreviousHaiku==NO) {
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
    CGSize xySize = [self.rightSwipe.text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:largeFontSize]];
    
                //We need xySize.width*1.5 and xySize.height*2 because using just xySize.width and xySize.height cuts off the text--UITextView has padding built in.

    CGRect rect = CGRectMake((screenWidth - xySize.width-30), screenHeight-240, xySize.width*1.5, xySize.height*2);
    self.rightSwipe.frame = rect;
    
                //Display it.
    
    [self.view addSubview:self.rightSwipe];
}

-(void)addSwipeForPreviousView {
    
                //Create "swipe" message to be shown with second haiku and set its location.
    
    self.leftSwipe = [self createSwipeToAdd];
    CGSize xySize = [self.leftSwipe.text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:largeFontSize]];
    
                //We need xySize.width*1.5 and xySize.height*2 because using just xySize.width and xySize.height cuts off the text--UITextView has padding built in.
    
    CGRect rect = CGRectMake(10, screenHeight-240, xySize.width*1.5, xySize.height*2);
    self.leftSwipe.frame = rect;
    
                //Display it
    
    [self.view addSubview:self.leftSwipe];
}

#pragma mark NAVIGATION METHODS

-(void)goToNextHaiku {
    
                //Increase the index by one.
    
    self.ghhaiku.newIndex++;
    
                //Set boolean for direction of animation.
    
    self.appIsComingFromPreviousHaiku=NO;
    
                //Show next haiku in array
    
    [self displayHaiku];
    
                //Show swipe instructions if appropriate and adjust booleans accordingly
    
    if (self.leftSwipeHasBeenSeen==NO) {
        [self addSwipeForPreviousView];
        self.leftSwipeHasBeenSeen=YES;
    }
    else {
        [self.leftSwipe removeFromSuperview];
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
        
    self.appIsComingFromPreviousHaiku=YES;
        
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
    [self.navBar removeFromSuperview];
    
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

/*
-(void)openMail {
    
                //Open Mail program and create email with haiku attached as image.
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:[NSString stringWithFormat:@"Gay Haiku"]];
        UIImage *myImage = [self addTextToImage:[UIImage imageNamed: @"backgroundForFacebook.png"] withFontSize:15];
        NSData *imageData = UIImagePNGRepresentation(myImage);
        [mailer addAttachmentData:imageData mimeType:@"image/jpg" fileName:@"Gay Haiku http://gayhaiku.com"];
        NSString *emailBody = @"I thought you might like this gay haiku from the Gay Haiku iPhone app.";
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
    if (result == MFMailComposeResultSent) {
    self.alert = [[UIAlertView alloc] initWithTitle:@"Email sent." message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [self.alert show];
    }
}
*/

-(void)share {
    DMActivityInstagram *activity = [[DMActivityInstagram alloc] init];
    UIImage *myImage = [self addTextToImage:[UIImage imageNamed:@"backgroundForFacebook"] withFontSize:15];
    myImage = [self resizeImage:myImage inRect:CGRectMake(0, 0, 612, 612)];
    NSString *shareText = self.ghhaiku.text;
    shareText = [shareText stringByAppendingString:@"\n\n#gayhaiku"];
    NSURL *shareURL = [NSURL URLWithString:@"http://gayhaiku.com"];
    NSArray *activityItems = @[myImage, shareText, shareURL];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:@[activity]];
    [self presentViewController:activityController animated:YES completion:nil];
    NSLog(@"Yup!");
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
    UIActivity *activity;
    [activity activityDidFinish:YES];
    NSLog(@"Sent to instagram.");
}

-(UITextView *)createTextViewForDisplay:(NSString *)s {
    UITextView *tv = [[UITextView alloc] init];
    tv.font=[UIFont fontWithName:@"Georgia" size:mediumFontSize];
    tv.editable=NO;
    tv.userInteractionEnabled=NO;
    tv.backgroundColor=[UIColor clearColor];
    tv.text=s;
    return tv;
}

-(UIImage *)addTextToImage:(UIImage *)myImage withFontSize:(int)sz {
    GHVerify *ghv = [[GHVerify alloc] init];
    NSString *string=[ghv removeAuthor:self.displayHaikuTextView.text];
    NSString *myWatermarkText = [string stringByAppendingString:@"\n\n\t--gayhaiku.com"];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Georgia" size:sz], NSFontAttributeName, nil];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:myWatermarkText attributes:attrs];
    UIGraphicsBeginImageContextWithOptions(myImage.size,NO,1.0);
    [myImage drawAtPoint: CGPointZero];
    NSString *longestLine = ghv.listOfLines[1];
    CGSize sizeOfLongestLine = [longestLine sizeWithFont:[UIFont fontWithName:@"Georgia" size:sz]];
    CGSize siz = CGSizeMake(sizeOfLongestLine.width, sizeOfLongestLine.height*4);    [attString drawAtPoint: CGPointMake(myImage.size.width/2 - siz.width/2, myImage.size.height/2-siz.height/2)];
    myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return myImage;
}

-(UIImage *)resizeImage:(UIImage *)im inRect:(CGRect) thumbRect {
	CGImageRef			imageRef = [im CGImage];
	CGImageAlphaInfo	alphaInfo = CGImageGetAlphaInfo(imageRef);
	
	// There's a wierdness with kCGImageAlphaNone and CGBitmapContextCreate
	// see Supported Pixel Formats in the Quartz 2D Programming Guide
	// Creating a Bitmap Graphics Context section
	// only RGB 8 bit images with alpha of kCGImageAlphaNoneSkipFirst, kCGImageAlphaNoneSkipLast, kCGImageAlphaPremultipliedFirst,
	// and kCGImageAlphaPremultipliedLast, with a few other oddball image kinds are supported
	// The images on input here are likely to be png or jpeg files
	if (alphaInfo == kCGImageAlphaNone)
		alphaInfo = kCGImageAlphaNoneSkipLast;
    
	// Build a bitmap context that's the size of the thumbRect
	CGContextRef bitmap = CGBitmapContextCreate(
                                                NULL,
                                                thumbRect.size.width,		// width
                                                thumbRect.size.height,		// height
                                                CGImageGetBitsPerComponent(imageRef),	// really needs to always be 8
                                                4 * thumbRect.size.width,	// rowbytes
                                                CGImageGetColorSpace(imageRef),
                                                alphaInfo
                                                );
    
	// Draw into the context, this scales the image
	CGContextDrawImage(bitmap, thumbRect, imageRef);
    
	// Get an image from the context and a UIImage
	CGImageRef	ref = CGBitmapContextCreateImage(bitmap);
	UIImage*	result = [UIImage imageWithCGImage:ref];
    
	CGContextRelease(bitmap);	// ok if NULL
	CGImageRelease(ref);
    
	return result;
}

@end