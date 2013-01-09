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
    userSettings = [GHUserSettings sharedInstance];
    [userSettings setUserDefaults];
    
            //Uncomment next line for testing.
    
    //userSettings.optOutSeen=NO;
    
    if (userSettings.instructionsSwipedToFromOptOut==NO) {
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchToInstructions)];
        swipeLeft.numberOfTouchesRequired = 1;
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:swipeLeft];
    }
    
                //Add the background image.
    
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGRect frame = CGRectMake(0, 0, screenWidth, (screenHeight-tabBarHeight));
    UIImageView *background = [[UIImageView alloc] initWithFrame:frame];
    if (screenHeight<500) {
        background.image=[UIImage imageNamed:@"temp background.jpg"];
    }
    else {
        background.image=[UIImage imageNamed:@"iPhone5 temp background.jpg"];
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
    if (userSettings.optOutSeen==YES) {
        [swipeInstructions removeFromSuperview];
    }
    else {
        [self addSwipeForRight];
    }
    userSettings.optOutSeen=YES;
    [userSettings.defaults setBool:YES forKey:@"optOutSeen?"];
    [userSettings.defaults synchronize];
}

-(void)addSwipeForRight {

                //Create the text to tell the user to swipe to the next screen.
    
    swipeInstructions = [ghnumbers createSwipeToAdd:@"Next"];
    
                //Locate and frame the text on the right side of the view.
    
    CGSize dimensions = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 400); //Why did I choose 400?
    CGSize xySize = [swipeInstructions.text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:17] constrainedToSize:dimensions lineBreakMode:0];
    CGRect rect = CGRectMake((dimensions.width - xySize.width-30), [[UIScreen mainScreen] bounds].size.height-180, xySize.width*1.5, (xySize.height*2));
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
        settingsPartOne = [ghnumbers createParagraph:settingsPartOne];
        settingsPartOne.text = @"I hope to update the Gay Haiku app periodically with new haiku, and, if you'll allow me, I'd like permission to include your haiku in future updates.  If you're okay with my doing so, please enter your name here so I can give you credit.";
        settingsPartOne.frame = CGRectMake(screenWidth/2-(screenWidth-40)/2, ([[UIScreen mainScreen] bounds].size.height/2-125), screenWidth - 40, settingsHeight);
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
        settingsPartTwo = [ghnumbers createParagraph:settingsPartTwo];
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
