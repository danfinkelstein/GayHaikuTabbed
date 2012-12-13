//
//  GHComposeViewController.m
//  Gay Haiku
//
//  Created by Joel Derfner on 12/2/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import "GHComposeViewController.h"

@interface GHComposeViewController () <UITextViewDelegate,UIAlertViewDelegate,UITextFieldDelegate,UIActionSheetDelegate>

@end

@implementation GHComposeViewController

@synthesize checkboxChecked, textView, optOut, screenBackground, checkboxButton, nameField, alert, instructions, ghhaiku, instructionsSeen, optOutSeen, screen, nextInstructions, previousInstructions;

-(void)displayScreen:(int)x
{
    if (x==0)
    {
        [self displayComposeScreen];
    }
    else if (x==1)
    {
        [self displayInstructionsScreen];
    }
    else if (x==2)
    {
        [self displayOptOutScreen];
    }
}

-(int)chooseRightSwipeMethod

//PROBLEM:  this works when instructionsSeen and optOutSeen are set to NO in viewDidLoad but not when they're set to default and default is YES--in the latter case, it's impossible to right swipe from displayInstructionsScreen to displayComposeScreen.  What's going on?

{
    if (self.screen-1>=0)
    {
        [self displayScreen:screen-1];        
    }
    return 0;
}

-(int)chooseLeftSwipeMethod
{
    if (self.screen+1<=2)
    {
        [self displayScreen:screen+1];
    }
    return 0;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //Create and add swipe gesture recognizers
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(chooseRightSwipeMethod)];
    swipeRight.numberOfTouchesRequired = 1;
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(chooseLeftSwipeMethod)];
    swipeLeft.numberOfTouchesRequired = 1;
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    //load user defaults
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"optOutSeen?"])
    {
        self.optOutSeen = [defaults boolForKey:@"optOutSeen?"];
    }
    if ([defaults boolForKey:@"instructionsSeen?"])
    {
        self.instructionsSeen = [defaults boolForKey:@"instructionsSeen?"];
    }
    if ([defaults boolForKey:@"checked?"])
    {
        self.checkboxChecked = [defaults boolForKey:@"checked?"];
    }
    else self.checkboxChecked = YES;
    
    //UNCOMMENT THESE LINES TO TEST OPTOUT/INSTRUCTIONS SEEN
    
    //self.optOutSeen=NO;
    //self.instructionsSeen=NO;
    
    if (!self.ghhaiku)
    {
        self.ghhaiku = [GHHaiku sharedInstance];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Should this whole method be replaced with viewWillAppear?
        
    //set background image
    
    UIImage *fullBackground = [UIImage imageNamed:@"temp background.jpg"];
    self.screenBackground.image = fullBackground;
    
    //send user to appropriate screen
    
    if (self.optOutSeen==NO)
    {
        [self displayOptOutScreen];
    }
    else if (self.instructionsSeen==NO)
    {
        [self displayInstructionsScreen];
    }
    else
    {
        [self displayComposeScreen];
    }
}

-(void)addSwipeForRight

//Adds the text telling the user to swipe right to continue.

{
    NSString *text=@"Swipe to continue";
    CGSize dimensions = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 400); //Why did I choose 400?
    CGSize xySize = [text sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:14] constrainedToSize:dimensions lineBreakMode:0];
    CGRect rect = CGRectMake((dimensions.width - xySize.width-10), 340, xySize.width, (xySize.height*2));
    self.nextInstructions = [[UITextView alloc] initWithFrame:(rect)];
    self.nextInstructions.editable=NO;
//Why doesn't this work?  [UIColor colorWithRed:123 green:47 blue:85 alpha:.75]; Replaced it with next line and changing text color to purple.
    self.nextInstructions.backgroundColor = [UIColor clearColor];
    self.nextInstructions.text = text;
    self.nextInstructions.textColor = [UIColor purpleColor];
    
    [self.view addSubview:self.nextInstructions];
}

-(void)addSwipeForLeft

//Adds the text telling the user to swipe left to opt out.

{
    NSString *text = @"Swipe to opt out.";
    CGSize dimensions = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 400); //Why did I choose 400?
    CGSize xySize = [text sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:14] constrainedToSize:dimensions lineBreakMode:0];
    CGRect rect = CGRectMake(10, 340, xySize.width, (xySize.height*2));
    self.previousInstructions = [[UITextView alloc] initWithFrame:(rect)];
    self.previousInstructions.editable=NO;
//Why doesn't this work?  [UIColor colorWithRed:123 green:47 blue:85 alpha:.75]; Replaced it with next line and changing text color to purple.self.previousInstructions.backgroundColor = [UIColor clearColor];
    self.previousInstructions.backgroundColor = [UIColor clearColor];
    self.previousInstructions.text = text;
    self.previousInstructions.textColor = [UIColor purpleColor];
    
    [self.view addSubview:self.previousInstructions];
}


-(void)animateView:(UIView *)tv withDirection: (NSString *)direction
{
    //set animation
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    if (direction==@"right") transition.subtype =kCATransitionFromRight;
    else if (direction==@"left") transition.subtype = kCATransitionFromLeft;
    transition.delegate = self;
    
    //set view
    
    [tv.layer addAnimation:transition forKey:nil];
}

-(void)keyboardWillShow:(NSNotification *)aNotification
{
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.view.frame;
    frame.size.height -= keyboardRect.size.height;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification *)aNotification
{
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)saveData

//Persistent record of whether user has seen instructions and opt out screen.

{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self.optOutSeen)
    {
        [defaults setBool:self.optOutSeen forKey:@"optOutSeen?"];
    }
    if (self.instructionsSeen)
    {
        [defaults setBool:self.instructionsSeen forKey:@"instructionsSeen?"];
    }
    [defaults synchronize];
}

-(void)displayComposeScreen
{
    
    [self.nextInstructions removeFromSuperview];
    [self.previousInstructions removeFromSuperview];
    
//Still to come:  there will be an image specifically for entering user haiku, so at some point in this method the UIImageView in the Interface Builder will have to be hidden and a new UIImageView created to show that image.

    //Hide the instructions and opt-out.
    
    self.instructions.hidden=YES;
    self.optOut.hidden=YES;
    self.checkboxButton.hidden=YES;
    self.nameField.hidden=YES;
    
    //Create the textView if it doesn't exist.
    
    if (!self.textView)
    {
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, 280, 150)];
        self.textView.backgroundColor = [UIColor whiteColor];
    }
    
    //Set the textView's attributes and delegate.
    
    [self addTranslucentToolbarAboveKeyboard];
    self.textView.editable=YES;
    self.textView.delegate = self;
    self.textView.hidden=NO;
    [self.textView becomeFirstResponder];
    self.textView.text = @"";
    [self.view addSubview:self.textView];
    
    //Set the compose screen's background
    
//REPLACE THIS LATER WITH CORRECT IMAGE.
    UIImage *fullBackground = [UIImage imageNamed:@"temp background.jpg"];
    self.screenBackground.image = fullBackground;
    self.screen=0;
    [self animateView:self.view withDirection:@"right"];
}

-(void)addTranslucentToolbarAboveKeyboard
{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];

    UIBarButtonItem *instructionsButton = [[UIBarButtonItem alloc] initWithTitle:@"Instructions" style:UIBarButtonItemStyleBordered target:self action:NSSelectorFromString(@"displayInstructionsScreen")];
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard)];

    NSArray *itemsArray = [NSArray arrayWithObjects:instructionsButton, flexButton, doneButton, nil];

    [toolbar setItems:itemsArray];
    [self.textView setInputAccessoryView:toolbar];
}
    
-(void)resignKeyboard
{
    [self.textView resignFirstResponder];
    [self doActionSheet];
}

-(void)displayInstructionsScreen
{
    //Hide the textView.
    
    self.optOut.hidden=YES;
    [self.nextInstructions removeFromSuperview];
    [self.previousInstructions removeFromSuperview];
    self.checkboxButton.hidden=YES;
    self.nameField.hidden=YES;
    self.textView.hidden=YES;
    [self.textView resignFirstResponder];
    
    //Create the instructions if they don't exist and set their attributes.
    
    if (!self.instructions)
    {
        self.instructions = [[UITextView alloc] initWithFrame:CGRectMake(10, 125, [[UIScreen mainScreen] bounds].size.width - 10, [[UIScreen mainScreen] bounds].size.height)];
        self.instructions.backgroundColor=[UIColor clearColor];
        self.instructions.text = @"\nFor millennia, the Japanese haiku has allowed great thinkers to express their ideas about the world in three lines of five, seven, and five syllables respectively.  \n\nContrary to popular belief, the three lines need not be three separate sentences.  Rather, either the first two lines are one thought and the third is another or the first line is one thought and the last two are another; the two thoughts are often separated by punctuation.\n\nHave a fabulous time composing your own gay haiku!";
        self.instructions.editable=NO;
    }
    if (self.screen==0) [self animateView:self.instructions withDirection:@"left"];
    else if (self.screen==2) [self animateView:self.instructions withDirection:@"right"];
    //if (self.instructionsSeen==NO)
    {
        [self addSwipeForLeft];
        [self addSwipeForRight];
        self.instructionsSeen=YES;
        [self saveData];
    }
    self.instructions.hidden=NO;
    self.screen=1;
    [self.view addSubview:self.instructions];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)displayOptOutScreen
{
    
    //Hide the textView and instructions.
    
    self.textView.hidden=YES;
    self.instructions.hidden=YES;
    [self.nextInstructions removeFromSuperview];
    [self.previousInstructions removeFromSuperview];
    
    //Create the optOut text if it doesn't exist and set its attributes.
    
    if (!self.optOut)
    {
        self.optOut = [[UITextView alloc] initWithFrame:CGRectMake(20, 90, [[UIScreen mainScreen] bounds].size.width - 20, [[UIScreen mainScreen] bounds].size.height)];
        self.optOut.backgroundColor=[UIColor clearColor];
        self.optOut.text = @"\nI hope to update the Gay Haiku app periodically with new haiku, and, if you'll allow me, I'd like permission to include your haiku in future updates.  If you're okay with my doing so, please enter your name here so I can give you credit.\n\n\n\nIf you don't want your haiku included in \nfuture updates (which would make me \nsad), check this box.";
        self.optOut.editable=NO;
    }
    if (self.screen==1) [self animateView:self.optOut withDirection:@"left"];
    else [self animateView:self.optOut withDirection:@"right"];
    [self.view addSubview:self.optOut];
    self.optOut.hidden=NO;
    self.checkboxButton.hidden=NO;
    [self.textView resignFirstResponder];
    if (!self.nameField)
    {
        self.nameField=[[UITextField alloc] init];
    }
    for(UIView *view in [self view].subviews){
        [view setUserInteractionEnabled:YES];
    }
    [self.instructions removeFromSuperview];
    self.nameField.hidden=NO;
    self.nameField.delegate = self;
    self.nameField.returnKeyType = UIReturnKeyDone;
    [self textFieldShouldReturn:self.nameField];
    [self.view bringSubviewToFront:self.checkboxButton];
    [self.view bringSubviewToFront:self.nameField];
    self.screen=2;
    
    //if (self.optOutSeen==NO)
    {
        [self addSwipeForRight];
        self.optOutSeen=YES;
        [self saveData];
    }
}

-(void)displayButton
{
    if (self.checkboxChecked)
    {
        [self.checkboxButton setImage:[UIImage imageNamed:@"trycheckbox_no.png"] forState:UIControlStateNormal];
    }
    else if (!self.checkboxChecked)
    {
        [self.checkboxButton setImage:[UIImage imageNamed:@"trycheckbox.png"] forState:UIControlStateNormal];
    }
}

-(void)userFinishedWritingHaiku
{
    if (!self.textView || self.textView.text.length==0)
    {
        [self.tabBarController setSelectedIndex:0];
    }
    else
    {
        [self doActionSheet];
    }
}

-(void)doActionSheet
{
    //self.textToSave=self.textView;
    [self.textView resignFirstResponder];
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:nil delegate: self cancelButtonTitle:@"Continue Editing" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Save", nil]; // @"Opt Out", nil];
    [actSheet showFromTabBar:self.tabBarController.tabBar];
}

-(void)actionSheet:(UIActionSheet *)actSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0)
    {
        self.textView.text=@"";
        [self.tabBarController setSelectedIndex:0];
    }
    else if (buttonIndex==1)
    {
        [self saveUserHaiku];
    }
    else
    {
        [actSheet dismissWithClickedButtonIndex:2 animated:YES];
        [self.textView becomeFirstResponder];
    }
}

-(void)saveUserHaiku
{
    if (self.textView.text.length>0)
    {
        NSArray *quotes = [[NSArray alloc] initWithObjects:@"user", self.textView.text, nil];
        NSArray *keys = [[NSArray alloc] initWithObjects:@"category",@"quote",nil];
        NSDictionary *dictToSave = [[NSDictionary alloc] initWithObjects:quotes forKeys:keys];
        int i;
        for (i=0; i<self.ghhaiku.gayHaiku.count; i++)
        {
            NSString *haikuToCheck = [[self.ghhaiku.gayHaiku objectAtIndex:i] valueForKey:@"quote"];
            if ([self.textView.text isEqualToString:haikuToCheck])
            {
                [self.tabBarController setSelectedIndex:0];
            }
        }
        [self.ghhaiku.gayHaiku addObject:dictToSave];
        NSLog(@"%@",[self.ghhaiku.gayHaiku lastObject]);
        [self.ghhaiku saveToDocsFolder:@"userHaiku.plist"];
        
        PFObject *haikuObject = [PFObject objectWithClassName:@"TestObject"];
        [haikuObject setObject:self.textView.text forKey:@"haiku"];
        if (self.nameField.text)
        {
            [haikuObject setObject:self.nameField.text forKey:@"author"];
        }
        NSString *perm;
        if (self.checkboxChecked)
        {
            perm=@"Yes";
        }
        else
        {
            perm=@"No";
        }
        [haikuObject setObject:perm forKey:@"permission"];
        [haikuObject saveEventually];
        self.ghhaiku.justComposed=YES;
        [self.textView removeFromSuperview];
        [self.tabBarController setSelectedIndex:0];
    }
}

- (IBAction)checkCheckbox
{
    self.checkboxChecked=!self.checkboxChecked;
    [self displayButton];
    NSLog(@"box checked? %d", self.checkboxChecked);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.checkboxChecked forKey:@"checked?"];
    [defaults synchronize];
}

@end
