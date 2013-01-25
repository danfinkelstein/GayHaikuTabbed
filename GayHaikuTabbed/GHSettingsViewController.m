//
//  GHSettingsViewController.m
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 1/6/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import "GHSettingsViewController.h"

@interface GHSettingsViewController () <UITextFieldDelegate>

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
    
    userSettings = [GHAppDefaults sharedInstance];
    [userSettings setUserDefaults];
    screenWidth=self.view.bounds.size.width;
    screenHeight=self.view.bounds.size.height;
    screenColor = [UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:1];
    
                //Uncomment next line for testing.
    
    //userSettings.optOutSeen=NO;
    
                //Add swipe gesure recognizer if user has never swiped from settings to instructions.
    
   if (userSettings.instructionsSwipedToFromOptOut==NO) {
       NSLog(@"Adding swipe gesture recognizer");
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
    background = [[UIImageView alloc] initWithFrame:frame];
    if (screenHeight<500) {
        background.image=[UIImage imageNamed:@"instructions.png"];
    }
    else {
        background.image=[UIImage imageNamed:@"5instructions.png"];
    }
    [self.view addSubview:background];
    [self.view sendSubviewToBack:background];
    
    if (userSettings.permissionDenied==NO) {
        permissionDenied.selectedSegmentIndex=0;
        [permissionDenied setTitle:@"Yes" forSegmentAtIndex:0];
    }
    else {
        permissionDenied.selectedSegmentIndex=1;
        [permissionDenied setTitle:@"No" forSegmentAtIndex:1];
    }
    if (userSettings.disableSyllableCheck==NO) {
        disableVerification.selectedSegmentIndex=0;
        [disableVerification setTitle:@"On" forSegmentAtIndex:0];
    }
    else {
        disableVerification.selectedSegmentIndex=1;
        [disableVerification setTitle:@"Off" forSegmentAtIndex:1];
    }
    nameField.delegate=self;
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
    if (userSettings.optOutSeen) {
        [swipeInstructions removeFromSuperview];
    }
    else {
        [self addSwipeForRight];
    }
    userSettings.optOutSeen=YES;
    [userSettings.defaults setBool:YES forKey:@"optOutSeen?"];
    [userSettings.defaults synchronize];
}

-(UITextView *)createSwipeToAdd: (NSString *)word {
    
    //Create "Swipe" text and its characteristics
    
    UITextView *instructions = [[UITextView alloc] init];
    instructions.editable=NO;
    instructions.textColor = screenColor;
    instructions.backgroundColor = [UIColor clearColor];
    instructions.text = word;
    instructions.userInteractionEnabled=NO;
    instructions.font = [UIFont fontWithName:@"Zapfino" size:largeFontSize];
    return instructions;
}

-(void)addSwipeForRight {

                //Create the text to tell the user to swipe to the next screen.
    
    swipeInstructions = [self createSwipeToAdd:@"Next"];
    
                //Locate and frame the text on the right side of the view.
    
    NSString *text = [swipeInstructions.text stringByAppendingString:@"compo"];
    CGSize dimensions = CGSizeMake(screenWidth, 400); //Why did I choose 400?
    CGSize xySize = [text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:largeFontSize] constrainedToSize:dimensions lineBreakMode:0];
    CGRect rect = CGRectMake((dimensions.width - xySize.width), screenHeight*0.75, xySize.width, xySize.height);
    swipeInstructions.frame = rect;
    
                //Display it.
    
    [self.view addSubview:swipeInstructions];
}

/*-(void)displaySettingsScreen {

    [infoAbout removeFromSuperview];
    [backButton removeFromSuperview];
    
                //Should these be put somewhere else?  They're really constants, not variables.  Above implementation?
    
    int nameFieldHeight = 31;
    int settingsHeight = 90;
    int gap = 10;
    
                //Create the optOut text if it doesn't exist and set its attributes.
    
    if (!settingsPartOne) {
        settingsPartOne = [[UITextView alloc] init];
        settingsPartOne.backgroundColor=[UIColor clearColor];
        settingsPartOne.font = [UIFont fontWithName:@"Helvetica Neue" size:smallFontSize];
        settingsPartOne.editable=NO;
        settingsPartOne.userInteractionEnabled=NO;
        settingsPartOne.text = @"I hope to update the Gay Haiku app with new haiku, and I'd like permission to include your haiku (or haiku inspired by yours) in future updates.  If you're okay with my doing so, please enter your name here so I can give you credit.";
        settingsPartOne.frame = CGRectMake(screenWidth/2-(screenWidth-40)/2, (screenHeight/2-113), screenWidth - 40, settingsHeight);
    }
    if (!nameField)
    {
        nameField=[[UITextField alloc] initWithFrame:CGRectMake(screenWidth/2-104, settingsPartOne.center.y + settingsHeight/2 + gap, 208, nameFieldHeight)];
        nameField.text=@"Name (optional)";
        nameField.textColor = [UIColor darkGrayColor];
        nameField.clearsOnBeginEditing=YES;
        nameField.backgroundColor = [UIColor clearColor];
        nameField.borderStyle=UITextBorderStyleNone;
        nameField.returnKeyType=UIReturnKeyDone;
        nameField.delegate=self;
        nameFieldImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"input.png"]];
        nameFieldImage.frame = CGRectMake(screenWidth/2-114, settingsPartOne.center.y + settingsHeight/2 + gap - 3, 228, 31);
    }

    if (userSettings.author) {
        nameField.text=userSettings.author;
    }
    if (!settingsPartTwo) {
        settingsPartTwo = [[UITextView alloc] init];
        settingsPartTwo.backgroundColor=[UIColor clearColor];
        settingsPartTwo.font = [UIFont fontWithName:@"Helvetica Neue" size:smallFontSize];
        settingsPartTwo.editable=NO;
        settingsPartTwo.text = @"If you DON'T want your haiku included \nin future updates (which would make \nme sad), check this box.";
        settingsPartTwo.frame = CGRectOffset(settingsPartOne.frame, 0, settingsHeight + gap + nameFieldHeight);
    }
    if (!checkboxButton) {
        checkboxButton = [UIButton buttonWithType:UIButtonTypeCustom];
        checkboxButton.frame = CGRectMake(screenWidth/2+((screenWidth-80)/2) - 44, nameField.center.y + nameFieldHeight/2 + gap, buttonSideLength, buttonSideLength);
        [checkboxButton setImage:[UIImage imageNamed:@"checkboxUnchecked.png"] forState:UIControlStateNormal];
        [checkboxButton addTarget:self action:@selector(checkCheckbox) forControlEvents:UIControlEventTouchUpInside];
    }
    NSString *textForSettingsThree = @"Gay Haiku v. 1.0, ©2012 by Joel Derfner. Thanks to Dan Finkelstein and beta testers. Graphics by iphone-icon.com.";
    UITextView *settingsThree = [[UITextView alloc] initWithFrame:CGRectMake(screenWidth/2-150, settingsHeight + gap + nameFieldHeight + gap + 200, 300, 100)];
    settingsThree.backgroundColor=[UIColor clearColor];
    settingsThree.text=textForSettingsThree;
    [self.view addSubview:settingsThree];
        aboutButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"About"]];
        [aboutButton setSegmentedControlStyle:UISegmentedControlStyleBar];
        aboutButton.tintColor = screenColor;
        [aboutButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor, nil] forState:UIControlStateNormal];
        CGSize size = [@"About" sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:largeFontSize + 12]];
        aboutButton.frame = CGRectMake(screenWidth/2 - size.width/2, screenHeight-size.height*4, size.width, size.height);
        aboutButton.tintColor = screenColor;
        [aboutButton addTarget:self action:@selector(showAbout) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:settingsPartOne];
    [self.view addSubview:nameFieldImage];
    [self.view addSubview:nameField];
    [self.view addSubview:settingsPartTwo];
    [self.view addSubview:checkboxButton];
    [self.view addSubview:aboutButton];

    
    for(UIView *view in [self view].subviews){
        [view setUserInteractionEnabled:YES];
    }

    [self textFieldShouldReturn:nameField];
}*/

/*-(void)showAbout {
    
                        //Clear the screen.
    
    [settingsPartOne removeFromSuperview];
    [settingsPartTwo removeFromSuperview];
    [checkboxButton removeFromSuperview];
    [aboutButton removeFromSuperview];
    [nameField removeFromSuperview];
    [nameFieldImage removeFromSuperview];
    
                        //Switch the back button.
    
        backButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Back"]];
        [backButton setSegmentedControlStyle:UISegmentedControlStyleBar];
        backButton.tintColor = screenColor;
        [backButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor, nil] forState:UIControlStateNormal];
        CGSize size = [@"Back" sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:largeFontSize + 12]];
        backButton.frame = CGRectMake(screenWidth/2 - size.width/2, screenHeight-size.height*4, size.width, size.height);
        [backButton addTarget:self action:@selector(displaySettingsScreen) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:backButton];
    
                //Add text.
    
    infoAbout = [[UITextView alloc] init];
    infoAbout.backgroundColor = [UIColor clearColor];
    infoAbout.font = [UIFont fontWithName:@"Helvetica Neue" size:mediumFontSize];
    infoAbout.editable=NO;
    infoAbout.text=@"Gay Haiku v. 1.0\n©2012 by Joel Derfner\n\nThanks to Dan Finkelstein and beta testers.\n\nGraphics by iphone-icon.com.";
    NSString *blah = @"Gay Haiku v. 1.0, ©2012 by Joel Derfner";
    CGSize xySize = [blah sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:mediumFontSize]];
    infoAbout.frame = CGRectMake(screenWidth/2-xySize.width/2, screenHeight/2-(xySize.height*10)/2, xySize.width+12, xySize.height*8);
    infoAbout.dataDetectorTypes=UIDataDetectorTypeLink;
    [self.view addSubview:infoAbout];
}*/

-(void)textFieldDidBeginEditing:(UITextField *)tF {
    [tF becomeFirstResponder];
}

-(void)textFieldDidEndEditing:(UITextField *)tF {
    
                //If user has entered text for "user name" field in Opt Out, save this information in user defaults so that this name will be associated with any future haiku written by this user.
    
    if (nameField.text.length>0) {
        userSettings.author=nameField.text;
        //userSettings.defaults = [NSUserDefaults standardUserDefaults];
        [userSettings.defaults setObject:nameField.text forKey:@"author"];
        [userSettings.defaults synchronize];
    }
}

/*-(void)displayButton {
    
                //Displays a checkmark if the user has opted out, a blank box if not.
    
    if (userSettings.checkboxUnchecked) {
        [checkboxButton setImage:[UIImage imageNamed:@"checkboxUnchecked.png"] forState:UIControlStateNormal];
    }
    else if (!userSettings.checkboxUnchecked) {
        [checkboxButton setImage:[UIImage imageNamed:@"checkboxChecked.png"] forState:UIControlStateNormal];
    }
}*/

/*- (void)checkCheckbox {
    
                //Change the checkbox setting.
    
    userSettings.checkboxUnchecked=!userSettings.checkboxUnchecked;
    
                //Display the results of the change.
    
    [self displayButton];
    
                //Update the defaults to reflect the change.
    
    [userSettings.defaults setBool:userSettings.checkboxUnchecked forKey:@"checked?"];
    [userSettings.defaults synchronize];
}*/

-(IBAction)givePermission:(UISegmentedControl *)sender {
    userSettings.permissionDenied=!userSettings.permissionDenied;
    [userSettings.defaults setBool:userSettings.permissionDenied forKey:@"permissionDenied?"];
    [userSettings.defaults synchronize];
    if (permissionDenied.selectedSegmentIndex==0) {
        [permissionDenied setTitle:@"Yes" forSegmentAtIndex:0];
        [permissionDenied setTitle:@"" forSegmentAtIndex:1];
    }
    else {
        [permissionDenied setTitle:@"" forSegmentAtIndex:0];
        [permissionDenied setTitle:@"No" forSegmentAtIndex:1];
    }
}

/*-(IBAction)determineTextSize:(UISegmentedControl *)sender {
    NSLog(@"large text: %d",userSettings.largeText);
    userSettings.largeText=!userSettings.largeText;
    [userSettings.defaults setBool:userSettings.largeText forKey:@"largeText?"];
    [userSettings.defaults synchronize];
    NSLog(@"large text: %d",userSettings.largeText);
    if (large.selectedSegmentIndex==0) {
        [large setTitle:@"Small" forSegmentAtIndex:0];
        [large setTitle:@"" forSegmentAtIndex:1];
    }
    else {
        [large setTitle:@"" forSegmentAtIndex:0];
        [large setTitle:@"Large" forSegmentAtIndex:1];
    }
    NSLog(@"%d",large.selectedSegmentIndex);
}*/

-(IBAction)disableSyllableVerification:(UISegmentedControl *)sender {
    userSettings.disableSyllableCheck=!userSettings.disableSyllableCheck;
    [userSettings.defaults setBool:userSettings.disableSyllableCheck forKey:@"disableSyllableCheck?"];
    [userSettings.defaults synchronize];
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
