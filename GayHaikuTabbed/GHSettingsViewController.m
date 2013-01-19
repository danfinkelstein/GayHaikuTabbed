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
    
                //Uncomment next line for testing.
    
    //userSettings.optOutSeen=NO;
    
                //Add swipe gesure recognizer if user has never swiped from settings to instructions.
    
   if (userSettings.instructionsSwipedToFromOptOut==NO) {
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchToInstructions)];
        swipeLeft.numberOfTouchesRequired = 1;
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:swipeLeft];
    }
    
                //Add the background image.
    
    CGRect frame;
    frame = CGRectMake(0, 0, screenWidth, (screenHeight-tabBarHeight));
    background = [[UIImageView alloc] initWithFrame:frame];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (screenHeight<500) {
            background.image=[UIImage imageNamed:@"instructions.png"];
        }
        else {
            background.image=[UIImage imageNamed:@"5instructions.png"];
        }
    }
    else {
        if (self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
            background.image=[UIImage imageNamed:@"iPad portrait GHViewController.jpg"];
        }
        else {
            background.image=[UIImage imageNamed:@"iPad landscape GHViewController.jpg"];
        }
    }
    [self.view addSubview:background];
    [self displaySettingsScreen];
}

-(void)switchToInstructions {
    if (userSettings.instructionsSwipedToFromOptOut==NO) {
        [self.tabBarController setSelectedIndex:1];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (userSettings.instructionsSwipedToFromOptOut==YES) {
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
    instructions.textColor = [UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:1];
    instructions.backgroundColor = [UIColor clearColor];
    instructions.text = word;
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
    CGRect rect = CGRectMake((dimensions.width - xySize.width), screenHeight*0.625, xySize.width, xySize.height);
    swipeInstructions.frame = rect;
    
                //Display it.
    
    [self.view addSubview:swipeInstructions];
}

-(void)displaySettingsScreen {

                //Should these be put somewhere else?  They're really constants, not variables.  Above implementation?
    
    int nameFieldHeight = 30;
    int settingsHeight = 90;
    int gap = 10;
    
                //Create the optOut text if it doesn't exist and set its attributes.
    
    if (!settingsPartOne) {
        settingsPartOne = [[UITextView alloc] init];
        settingsPartOne.backgroundColor=[UIColor clearColor];
        settingsPartOne.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
        settingsPartOne.editable=NO;
        settingsPartOne.text = @"I hope to update the Gay Haiku app periodically with new haiku, and, if you'll allow me, I'd like permission to include your haiku in future updates.  If you're okay with my doing so, please enter your name here so I can give you credit.";
        settingsPartOne.frame = CGRectMake(screenWidth/2-(screenWidth-40)/2, (screenHeight/2-125), screenWidth - 40, settingsHeight);
    }
    
    if (!nameField)
    {
        nameField=[[UITextField alloc] initWithFrame:CGRectMake(screenWidth/2-(screenWidth-80)/2, settingsPartOne.center.y + settingsHeight/2 + gap, screenWidth-80, nameFieldHeight)];
        nameField.borderStyle=UITextBorderStyleRoundedRect;
        nameField.backgroundColor = [UIColor colorWithRed:255/255.0 green:212/255.0 blue:227/255.0 alpha:1];
        nameField.placeholder=@"Name (optional)";
        nameField.clearsOnBeginEditing=YES;
        nameField.returnKeyType=UIReturnKeyDone;
        nameField.delegate=self;
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
        [checkboxButton setImage:[UIImage imageNamed:@"checkbox unchecked.png"] forState:UIControlStateNormal];
        [checkboxButton addTarget:self action:@selector(checkCheckbox) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:settingsPartOne];
    [self.view addSubview:nameField];
    [self.view addSubview:settingsPartTwo];
    [self.view addSubview:checkboxButton];

    
    for(UIView *view in [self view].subviews){
        [view setUserInteractionEnabled:YES];
    }

    [self textFieldShouldReturn:nameField];
}

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

-(void)displayButton {
    
                //Displays a checkmark if the user has opted out, a blank box if not.
    
    if (userSettings.checkboxChecked) {
        [checkboxButton setImage:[UIImage imageNamed:@"checkbox checked.png"] forState:UIControlStateNormal];
    }
    else if (!userSettings.checkboxChecked) {
        [checkboxButton setImage:[UIImage imageNamed:@"checkbox unchecked.png"] forState:UIControlStateNormal];
    }
}

- (void)checkCheckbox {
    
                //Change the checkbox setting.
    
    userSettings.checkboxChecked=!userSettings.checkboxChecked;
    
                //Display the results of the change.
    
    [self displayButton];
    
                //Update the defaults to reflect the change.
    
    [userSettings.defaults setBool:userSettings.checkboxChecked forKey:@"checked?"];
    [userSettings.defaults synchronize];
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
