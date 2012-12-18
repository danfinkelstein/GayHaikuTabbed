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

@synthesize checkboxChecked, textView, optOut, screenBackground, checkboxButton, nameField, alert, instructions, ghhaiku, instructionsSeen, optOutSeen, screen, nextInstructions, previousInstructions,instructionsHaveBeenSeenThisSession, optOutHasBeenSeenThisSession, ghverify, bypassSyllableCheck;

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
    
    self.bypassSyllableCheck=NO;
    
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
    NSString *text=@"Swipe";
    CGSize dimensions = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 400); //Why did I choose 400?
    CGSize xySize = [text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:14] constrainedToSize:dimensions lineBreakMode:0];
    CGRect rect = CGRectMake((dimensions.width - xySize.width-30), 340, xySize.width*1.5, (xySize.height*2));
    self.nextInstructions = [[UITextView alloc] initWithFrame:(rect)];
    self.nextInstructions.editable=NO;
//Why doesn't this work?  [UIColor colorWithRed:123 green:47 blue:85 alpha:.75]; Replaced it with next line and changing text color to purple.
    self.nextInstructions.backgroundColor = [UIColor clearColor];
    self.nextInstructions.text = text;
    self.nextInstructions.textColor = [UIColor purpleColor];
    self.nextInstructions.font = [UIFont fontWithName:@"Zapfino" size:14];
    [self.view addSubview:self.nextInstructions];
}

-(void)addSwipeForLeft
//Adds the text telling the user to swipe left to opt out.
{
    NSString *text = @"Swipe";
    CGSize dimensions = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 400); //Why did I choose 400?
    CGSize xySize = [text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:14] constrainedToSize:dimensions lineBreakMode:0];
    CGRect rect = CGRectMake(10, 340, xySize.width*1.5, (xySize.height*2));
//Why is there a line break after "opt"?  It should be just one line.
    self.previousInstructions = [[UITextView alloc] initWithFrame:(rect)];
    self.previousInstructions.editable=NO;
//Why doesn't this work?  [UIColor colorWithRed:123 green:47 blue:85 alpha:.75]; Replaced it with next line and changing text color to purple.self.previousInstructions.backgroundColor = [UIColor clearColor];
    self.previousInstructions.backgroundColor = [UIColor clearColor];
    self.previousInstructions.text = text;
    self.previousInstructions.textColor = [UIColor purpleColor];
    self.previousInstructions.font = [UIFont fontWithName:@"Zapfino" size:14];
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
        self.textView.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        self.textView.delegate = self;
    }
    
    //Set the textView's attributes and delegate.
    
    [self addTranslucentToolbarAboveKeyboard];
    self.textView.editable=YES;
    self.textView.hidden=NO;
    if (self.ghhaiku.userIsEditing==NO)
    {
        self.textView.text = @"";
    }
    else
    {
        self.textView.text = self.ghhaiku.text;
    }
    [self.view addSubview:self.textView];
    [self.textView becomeFirstResponder];
    
    //Set the compose screen's background
    
//REPLACE THIS LATER WITH CORRECT IMAGE.
    UIImage *composeBackground = [UIImage imageNamed:@"temp background.jpg"];
    self.screenBackground.image = composeBackground;
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
    //In case user is coming from the compose screen, which has a different background image.
    
    if (self.screenBackground.image!=[UIImage imageNamed:@"temp background.jpg"])
    {
        UIImage *fullBackground = [UIImage imageNamed:@"temp background.jpg"];
        self.screenBackground.image = fullBackground;
    }
    
    //Hide the appropriate views.
    
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
    if (self.instructionsSeen==NO)
    {
        self.instructionsSeen=YES;
        [self saveData];
    }
    if (self.instructionsHaveBeenSeenThisSession==NO)
    {
        [self addSwipeForLeft];
        [self addSwipeForRight];
    }
    self.instructionsHaveBeenSeenThisSession=YES;
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
        self.optOut = [[UITextView alloc] initWithFrame:CGRectMake(20, 95, [[UIScreen mainScreen] bounds].size.width - 20, [[UIScreen mainScreen] bounds].size.height)];
        self.optOut.backgroundColor=[UIColor clearColor];
        self.optOut.text = @"\n\nI hope to update the Gay Haiku app periodically with new haiku, and, if you'll allow me, I'd like permission to include your haiku in future updates.  If you're okay with my doing so, please enter your name here so I can give you credit.\n\n\n\nIf you don't want your haiku included in \nfuture updates (which would make me \nsad), check this box.";
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
    
    if (self.optOutSeen==NO)
    {
        self.instructionsSeen=YES;
        [self saveData];
    }
    if (self.optOutHasBeenSeenThisSession==NO)
    {
        [self addSwipeForRight];
    }
    self.optOutHasBeenSeenThisSession=YES;
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

-(void)doActionSheet
{
    [self.textView resignFirstResponder];
    UIActionSheet *actSheet;
    if (self.ghhaiku.userIsEditing)
    {
        
        //If user is editing a haiku that already exists
        
        if ([self.textView.text isEqualToString: self.ghhaiku.text])
            
            //If user hasn't made any changes
            
        {
            actSheet = [[UIActionSheet alloc] initWithTitle:nil delegate: self cancelButtonTitle:@"Continue Editing" destructiveButtonTitle:@"Dismiss" otherButtonTitles:nil];
        }
        else
            
            //If user has made changes
            
        {
            actSheet = [[UIActionSheet alloc] initWithTitle:nil delegate: self cancelButtonTitle:@"Continue Editing" destructiveButtonTitle:@"Discard Changes" otherButtonTitles:@"Save", nil];
        }
    }
    else
    {
        
        //If this is a new haiku
        
        actSheet = [[UIActionSheet alloc] initWithTitle:nil delegate: self cancelButtonTitle:@"Continue Editing" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Save", nil];      
    }
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

-(BOOL)saveUserHaiku
{
    
    //This makes sure the new haiku isn't a repeat of a haiku that's already in the database.
    
    int i;
    for (i=0; i<self.ghhaiku.gayHaiku.count; i++)
    {
        NSString *haikuToCheck = [[self.ghhaiku.gayHaiku objectAtIndex:i] valueForKey:@"quote"];
        if ([self.textView.text isEqualToString:haikuToCheck])
        {
            [self.tabBarController setSelectedIndex:0];
            
//Do we want to make the home screen display the haiku that's a repeat?  Probably....
            
            return YES;
        }
    }
    
    //This creates the dictionary item of the new haiku to save in userHaiku.plist.
    
    NSArray *quotes = [[NSArray alloc] initWithObjects:@"user", self.textView.text, nil];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"category",@"quote",nil];
    NSDictionary *dictToSave = [[NSDictionary alloc] initWithObjects:quotes forKeys:keys];

    //This checks to make sure the syllable counts are correct.
    
    if (self.bypassSyllableCheck==NO)
    {
        if (!self.ghverify)
        {
            self.ghverify = [[GHVerify alloc] init];
        }
    
        [self.ghverify splitHaikuIntoLines:self.textView.text];
        [self.ghverify checkHaikuSyllables];
    
        NSString *alertMessage=@"I'm sorry, but ";
    
        if (self.ghverify.correctNumberOfLines!=@"Just right.")
        {
            alertMessage = [alertMessage stringByAppendingFormat:@" %@",self.ghverify.correctNumberOfLines];
        }
        int k;
        if (self.ghverify.listOfLines.count<3)
        {
            k=self.ghverify.listOfLines.count;
        }
        else
        {
            k=3;
        }
        for (int i=0; i<k; i++)
        {
            if ([self.ghverify.linesAfterCheck objectAtIndex:i])
            {
                if (![[self.ghverify.linesAfterCheck objectAtIndex:i] isEqualToString:@"Just right."])
                {
                    if ([alertMessage characterAtIndex:alertMessage.length-1]=='.')
                    {
                        alertMessage = [alertMessage stringByAppendingFormat:@" Also, %@",[self.ghverify.linesAfterCheck objectAtIndex:i]];
                    }
                    else alertMessage = [alertMessage stringByAppendingFormat:@" %@",[self.ghverify.linesAfterCheck objectAtIndex:i]];
                }
            }
        }
        if (alertMessage.length>15)
        {
            NSString *add = @"Are you certain you'd like to continue saving?";
            alertMessage = [alertMessage stringByAppendingFormat:@" %@",add];
            self.alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:alertMessage delegate:self cancelButtonTitle:@"Edit" otherButtonTitles:@"Save", nil];
            [self.alert show];
            return YES;
        }
    }
    if (self.textView.text.length>0 && self.ghhaiku.userIsEditing==NO)
        
    //If it's a new haiku:
        
    {
        self.ghhaiku.newIndex++;
        [self.ghhaiku.gayHaiku insertObject:dictToSave atIndex:self.ghhaiku.newIndex];
    }
    
    //If it's an edited old haiku:
    
    else if (self.ghhaiku.userIsEditing==YES && self.textView.text.length>0)
    {
        
//Check this functionality.
        
        [self.ghhaiku.gayHaiku insertObject:dictToSave atIndex:self.ghhaiku.newIndex];
        [self.ghhaiku.gayHaiku removeObjectAtIndex:self.ghhaiku.newIndex+1];
    
        self.ghhaiku.userIsEditing=NO;
    }
    
    else if (!self.textView.text.length>0)
    {
        [self.tabBarController setSelectedIndex:0];
        return YES;
    }
    
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
    return YES;
}

- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger) buttonIndex
{
    if (buttonIndex == 0)
    {
        [self.textView becomeFirstResponder];
    }
    else if (buttonIndex == 1)
    {
        self.bypassSyllableCheck=YES;
        [self saveUserHaiku];
        self.bypassSyllableCheck=NO;
    }
}

- (IBAction)checkCheckbox
{
    self.checkboxChecked=!self.checkboxChecked;
    [self displayButton];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.checkboxChecked forKey:@"checked?"];
    [defaults synchronize];
}

@end
