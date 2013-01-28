//
//  GHSettingsViewController.m
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 1/6/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import "GHSettingsViewController.h"
#import "GHAppDefaults.h"

@interface GHSettingsViewController () <UITextFieldDelegate>

@property (nonatomic, strong) GHAppDefaults *userSettings;
@property (nonatomic, strong) UITextView *swipeInstructions;

@end

@implementation GHSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
                //Load user defaults.
    
    self.userSettings = [GHAppDefaults sharedInstance];
    [self.userSettings setUserDefaults];
    screenWidth=self.view.bounds.size.width;
    screenHeight=self.view.bounds.size.height;
    
                //Uncomment next line for testing.
    
    //userSettings.optOutSeen=NO;
    
                //Add swipe gesture recognizer if user has never swiped from settings to instructions.
    
   if (self.userSettings.instructionsSwipedToFromOptOut==NO) {
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchToInstructions)];
        swipeLeft.numberOfTouchesRequired = 1;
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:swipeLeft];
    }
    
                //Add tap gesture recognizer.
    
    UITapGestureRecognizer *tapScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayInfo)];
    [self.view addGestureRecognizer:tapScreen];
    
                //Add the background image.
    
    CGRect frame;
    frame = CGRectMake(0, 0, screenWidth, (screenHeight-tabBarHeight));
    UIImageView *background = [[UIImageView alloc] initWithFrame:frame];
    if (screenHeight<500) {
        background.image=[UIImage imageNamed:@"instructions.png"];
    }
    else {
        background.image=[UIImage imageNamed:@"5instructions.png"];
    }
    [self.view addSubview:background];
    [self.view sendSubviewToBack:background];
    
    if (self.userSettings.permissionDenied==NO) {
        permissionDenied.selectedSegmentIndex=0;
        [permissionDenied setTitle:@"Yes" forSegmentAtIndex:0];
    }
    else {
        permissionDenied.selectedSegmentIndex=1;
        [permissionDenied setTitle:@"No" forSegmentAtIndex:1];
    }
    if (self.userSettings.disableSyllableCheck==NO) {
        disableVerification.selectedSegmentIndex=0;
        [disableVerification setTitle:@"On" forSegmentAtIndex:0];
    }
    else {
        disableVerification.selectedSegmentIndex=1;
        [disableVerification setTitle:@"Off" forSegmentAtIndex:1];
    }
    nameField.delegate=self;
    
                //UNCOMMENT THIS FOR TESTING
    
    //userSettings.optOutSeen=NO;
}

-(void)switchToInstructions {
    [self.tabBarController setSelectedIndex:1];
}

-(void)displayInfo {
    UIAlertView *behindTheScenesInfo = [[UIAlertView alloc] initWithTitle:@"Gay Haiku v. 1.0" message:@"©2012 by Joel Derfner. Graphics by iphone-icon.com. Thanks to Dan Finkelstein, Matt Caldwell, and beta testers. " delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [behindTheScenesInfo show];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.userSettings.optOutSeen) {
        [self.swipeInstructions removeFromSuperview];
    }
    else {
        [self addSwipeForRight];
    }
}

-(UITextView *)createSwipeToAdd: (NSString *)word {
    
                //Create "Swipe" text and its characteristics
    
    UITextView *instructions = [[UITextView alloc] init];
    instructions.editable=NO;
    instructions.textColor = [UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:1];
    instructions.backgroundColor = [UIColor clearColor];
    instructions.text = word;
    instructions.userInteractionEnabled=NO;
    instructions.font = [UIFont fontWithName:@"Zapfino" size:largeFontSize];

    return instructions;
}

-(void)addSwipeForRight {

                //Create the text to tell the user to swipe to the next screen.
    
    self.swipeInstructions = [self createSwipeToAdd:@"Next"];
    
                //Locate and frame the text on the right side of the view.
    
    NSString *text = [self.swipeInstructions.text stringByAppendingString:@"compo"];
    CGSize dimensions = CGSizeMake(screenWidth, 400); //Why did I choose 400?
    CGSize xySize = [text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:largeFontSize] constrainedToSize:dimensions lineBreakMode:0];
    CGRect rect = CGRectMake((dimensions.width - xySize.width), screenHeight*0.75, xySize.width, xySize.height);
    self.swipeInstructions.frame = rect;
    self.userSettings.optOutSeen=YES;
    [self.userSettings.defaults setBool:YES forKey:@"optOutSeen?"];
    [self.userSettings.defaults synchronize];
    
                //Display it.
    
    [self.view addSubview:self.swipeInstructions];
}

-(void)textFieldDidBeginEditing:(UITextField *)tF {
    [tF becomeFirstResponder];
}

-(void)textFieldDidEndEditing:(UITextField *)tF {
    
                //If user has entered text for "user name" field in Opt Out, save this information in user defaults so that this name will be associated with any future haiku written by this user.
    
    if (nameField.text.length>0) {
        self.userSettings.author=nameField.text;
        [self.userSettings.defaults setObject:nameField.text forKey:@"author"];
        [self.userSettings.defaults synchronize];
    }
}

-(IBAction)givePermission:(UISegmentedControl *)sender {
    
                //Change the bool for the permissionDenied property and synchronize the default.
    
    self.userSettings.permissionDenied=!self.userSettings.permissionDenied;
    [self.userSettings.defaults setBool:self.userSettings.permissionDenied forKey:@"permissionDenied?"];
    [self.userSettings.defaults synchronize];
    
                //Change the display of the UISegmentedControl
    
    if (permissionDenied.selectedSegmentIndex==0) {
        [permissionDenied setTitle:@"Yes" forSegmentAtIndex:0];
        [permissionDenied setTitle:@"" forSegmentAtIndex:1];
    }
    else {
        [permissionDenied setTitle:@"" forSegmentAtIndex:0];
        [permissionDenied setTitle:@"No" forSegmentAtIndex:1];
    }
}

-(IBAction)disableSyllableVerification:(UISegmentedControl *)sender {
    
                //Change the bool for the disableVerification property and synchronize the default.
    
    self.userSettings.disableSyllableCheck=!self.userSettings.disableSyllableCheck;
    [self.userSettings.defaults setBool:self.userSettings.disableSyllableCheck forKey:@"disableSyllableCheck?"];
    [self.userSettings.defaults synchronize];
    
                //Change the display of the UISegmentedControl
    
    if (disableVerification.selectedSegmentIndex==0) {
        [disableVerification setTitle:@"On" forSegmentAtIndex:0];
        [disableVerification setTitle:@"" forSegmentAtIndex:1];
    }
    else {
        [disableVerification setTitle:@"" forSegmentAtIndex:0];
        [disableVerification setTitle:@"Off" forSegmentAtIndex:1];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
