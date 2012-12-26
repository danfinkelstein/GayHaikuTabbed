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

@synthesize screenBackground, checkboxButton, nameField; //, bypassSyllableCheck, instructionsSeen, optOutSeen, alert, checkboxChecked, optOutHasBeenSeenThisSession, instructionsHaveBeenSeenThisSession, textView, instructions, optOut, screen, nextInstructions, previousInstructions, , ghhaiku, ghverify;

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
    if (screen-1>=0)
    {
        [self displayScreen:screen-1];        
    }
    return 0;
}

-(int)chooseLeftSwipeMethod
{
    if (screen+1<=2)
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
        optOutSeen = [defaults boolForKey:@"optOutSeen?"];
    }
    if ([defaults boolForKey:@"instructionsSeen?"])
    {
        instructionsSeen = [defaults boolForKey:@"instructionsSeen?"];
    }
    if ([defaults boolForKey:@"checked?"])
    {
        checkboxChecked = [defaults boolForKey:@"checked?"];
    }
    else checkboxChecked = YES;
    
    //UNCOMMENT THESE LINES TO TEST OPTOUT/INSTRUCTIONS SEEN
    
    //self.optOutSeen=NO;
    //self.instructionsSeen=NO;
    
    if (!ghhaiku)
    {
        ghhaiku = [GHHaiku sharedInstance];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    bypassSyllableCheck=NO;
    
    //set background image
    
    UIImage *fullBackground = [UIImage imageNamed:@"temp background.jpg"];
    self.screenBackground.image = fullBackground;
    
    //send user to appropriate screen
    
    if (optOutSeen==NO)
    {
        [self displayOptOutScreen];
    }
    else if (instructionsSeen==NO)
    {
        [self displayInstructionsScreen];
    }
    else
    {
        
        [self displayComposeScreen];
    }
}

-(UITextView *)createSwipeToAdd {
    NSString *text = @"Swipe";
    UITextView *show = [[UITextView alloc] init];
    show.editable=NO;
    //Why doesn't this work?  [UIColor colorWithRed:123 green:47 blue:85 alpha:.75]; Replaced it with next line and changing text color to purple.
    show.textColor = [UIColor purpleColor];
    show.backgroundColor = [UIColor clearColor];
    show.text = text;
    show.font = [UIFont fontWithName:@"Zapfino" size:14];
    
    //Display it.
    
    return show;
}

-(void)addSwipeForRight
//Adds the text telling the user to swipe right to continue.
{
    nextInstructions = [self createSwipeToAdd];
    CGSize dimensions = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 400); //Why did I choose 400?
    CGSize xySize = [nextInstructions.text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:14] constrainedToSize:dimensions lineBreakMode:0];
    CGRect rect = CGRectMake((dimensions.width - xySize.width-30), 340, xySize.width*1.5, (xySize.height*2));
    nextInstructions.frame = rect; //[[UITextView alloc] initWithFrame:(rect)];
        
    //Display it.
        
    [self.view addSubview:nextInstructions];
}

-(void)addSwipeForLeft
//Adds the text telling the user to swipe left to opt out.
{
    previousInstructions = [self createSwipeToAdd];
    CGSize dimensions = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 400); //Why did I choose 400?
    CGSize xySize = [nextInstructions.text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:14] constrainedToSize:dimensions lineBreakMode:0];
    CGRect rect = CGRectMake(10, 340, xySize.width*1.5, (xySize.height*2));
    previousInstructions.frame = rect;
    
    [self.view addSubview:previousInstructions];
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
    if (optOutSeen)
    {
        [defaults setBool:optOutSeen forKey:@"optOutSeen?"];
    }
    if (instructionsSeen)
    {
        [defaults setBool:instructionsSeen forKey:@"instructionsSeen?"];
    }
    [defaults synchronize];
}

-(void)displayComposeScreen
{
    [nextInstructions removeFromSuperview];
    [previousInstructions removeFromSuperview];
        
    //Hide the instructions and opt-out.
    
    instructions.hidden=YES;
    optOut.hidden=YES;
    self.checkboxButton.hidden=YES;
    self.nameField.hidden=YES;
    
    //Create the textView if it doesn't exist.
    
    if (!textView)
    {
        textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, 280, 150)];
        textView.backgroundColor = [UIColor whiteColor];
        textView.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        textView.delegate = self;
    }
    
    //Set the textView's attributes and delegate.
    
    [self addTranslucentToolbarAboveKeyboard];
    textView.editable=YES;
    textView.hidden=NO;
    if (ghhaiku.userIsEditing==NO)
    {
        textView.text = @"";
    }
    else
    {
        textView.text = ghhaiku.text;
    }
    [self.view addSubview:textView];
    [textView becomeFirstResponder];
    
    //Set the compose screen's background
    
//REPLACE THIS LATER WITH CORRECT IMAGE.
    UIImage *composeBackground = [UIImage imageNamed:@"temp background.jpg"];
    self.screenBackground.image = composeBackground;
    screen=0;
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
    [textView setInputAccessoryView:toolbar];
}
    
-(void)resignKeyboard
{
    [textView resignFirstResponder];
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
    
    optOut.hidden=YES;
    [nextInstructions removeFromSuperview];
    [previousInstructions removeFromSuperview];
    self.checkboxButton.hidden=YES;
    self.nameField.hidden=YES;
    textView.hidden=YES;
    [textView resignFirstResponder];
    
    //Create the instructions if they don't exist and set their attributes.
    
    if (!instructions)
    {
        instructions = [[UITextView alloc] initWithFrame:CGRectMake(10, 125, [[UIScreen mainScreen] bounds].size.width - 10, [[UIScreen mainScreen] bounds].size.height)];
        instructions.backgroundColor=[UIColor clearColor];
        instructions.text = @"\nFor millennia, the Japanese haiku has allowed great thinkers to express their ideas about the world in three lines of five, seven, and five syllables respectively.  \n\nContrary to popular belief, the three lines need not be three separate sentences.  Rather, either the first two lines are one thought and the third is another or the first line is one thought and the last two are another; the two thoughts are often separated by punctuation.\n\nHave a fabulous time composing your own gay haiku!";
        instructions.editable=NO;
    }
    if (screen==0) [self animateView:instructions withDirection:@"left"];
    else if (screen==2) [self animateView:instructions withDirection:@"right"];
    if (instructionsSeen==NO)
    {
        instructionsSeen=YES;
        [self saveData];
    }
    if (instructionsHaveBeenSeenThisSession==NO)
    {
        [self addSwipeForLeft];
        [self addSwipeForRight];
    }
    instructionsHaveBeenSeenThisSession=YES;
    instructions.hidden=NO;
    screen=1;
    [self.view addSubview:instructions];
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
    
    textView.hidden=YES;
    instructions.hidden=YES;
    [nextInstructions removeFromSuperview];
    [previousInstructions removeFromSuperview];
    
    //Create the optOut text if it doesn't exist and set its attributes.
    
    if (!optOut)
    {
        optOut = [[UITextView alloc] initWithFrame:CGRectMake(20, 95, [[UIScreen mainScreen] bounds].size.width - 20, [[UIScreen mainScreen] bounds].size.height)];
        optOut.backgroundColor=[UIColor clearColor];
        optOut.text = @"\n\nI hope to update the Gay Haiku app periodically with new haiku, and, if you'll allow me, I'd like permission to include your haiku in future updates.  If you're okay with my doing so, please enter your name here so I can give you credit.\n\n\n\nIf you don't want your haiku included in \nfuture updates (which would make me \nsad), check this box.";
        optOut.editable=NO;
    }
    if (screen==1) [self animateView:optOut withDirection:@"left"];
    else [self animateView:optOut withDirection:@"right"];
    [self.view addSubview:optOut];
    optOut.hidden=NO;
    self.checkboxButton.hidden=NO;
    [textView resignFirstResponder];
    if (!self.nameField)
    {
        self.nameField=[[UITextField alloc] init];
    }
    for(UIView *view in [self view].subviews){
        [view setUserInteractionEnabled:YES];
    }
    [instructions removeFromSuperview];
    self.nameField.hidden=NO;
    self.nameField.delegate = self;
    self.nameField.returnKeyType = UIReturnKeyDone;
    [self textFieldShouldReturn:self.nameField];
    [self.view bringSubviewToFront:self.checkboxButton];
    [self.view bringSubviewToFront:self.nameField];
    screen=2;
    
    if (optOutSeen==NO)
    {
        instructionsSeen=YES;
        [self saveData];
    }
    if (optOutHasBeenSeenThisSession==NO)
    {
        [self addSwipeForRight];
    }
    optOutHasBeenSeenThisSession=YES;
}

-(void)displayButton
{
    if (checkboxChecked)
    {
        [self.checkboxButton setImage:[UIImage imageNamed:@"trycheckbox_no.png"] forState:UIControlStateNormal];
    }
    else if (!checkboxChecked)
    {
        [self.checkboxButton setImage:[UIImage imageNamed:@"trycheckbox.png"] forState:UIControlStateNormal];
    }
}

-(void)doActionSheet
{
    [textView resignFirstResponder];
    UIActionSheet *actSheet;
    if (ghhaiku.userIsEditing)
    {
        
        //If user is editing a haiku that already exists
        
        if ([textView.text isEqualToString: ghhaiku.text])
            
            //If user hasn't made any changes
        {
            textView.text=@"";
            [self.tabBarController setSelectedIndex:0];
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
        textView.text=@"";
        [self.tabBarController setSelectedIndex:0];
    }
    else if (buttonIndex==1)
    {
        [self saveUserHaiku];
    }
    else
    {
        [actSheet dismissWithClickedButtonIndex:2 animated:YES];
        [textView becomeFirstResponder];
    }
}

-(BOOL)saveUserHaiku
{
    
    //This makes sure the new haiku isn't a repeat of a haiku that's already in the database.  If it is, this dismisses the compose screen and puts the haiku already in the database on the main screen.
    
    int i;
    for (i=0; i<ghhaiku.gayHaiku.count; i++)
    {
        NSString *haikuToCheck = [[ghhaiku.gayHaiku objectAtIndex:i] valueForKey:@"quote"];
        if ([textView.text isEqualToString:haikuToCheck])
        {
            ghhaiku.justComposed=YES;
            ghhaiku.newIndex = i;
            [self.tabBarController setSelectedIndex:0];
            return YES;
        }
    }
    
    //This creates the dictionary item of the new haiku to save in userHaiku.plist.
    
    NSArray *quotes = [[NSArray alloc] initWithObjects:@"user", textView.text, nil];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"category",@"quote",nil];
    NSDictionary *dictToSave = [[NSDictionary alloc] initWithObjects:quotes forKeys:keys];

    //This checks to make sure the syllable counts are correct.
    
    if (bypassSyllableCheck==NO)
    {
        if (!ghverify)
        {
            ghverify = [[GHVerify alloc] init];
        }
    
        [ghverify splitHaikuIntoLines:textView.text];
        [ghverify checkHaikuSyllables];
    
        NSString *alertMessage=@"I'm sorry, but ";
    
        if (ghverify.correctNumberOfLines!=@"Just right.")
        {
            alertMessage = [alertMessage stringByAppendingFormat:@" %@",ghverify.correctNumberOfLines];
        }
        int k;
        if (ghverify.listOfLines.count<3)
        {
            k=ghverify.listOfLines.count;
        }
        else
        {
            k=3;
        }
        for (int i=0; i<k; i++)
        {
            if ([ghverify.linesAfterCheck objectAtIndex:i])
            {
                if (![[ghverify.linesAfterCheck objectAtIndex:i] isEqualToString:@"Just right."])
                {
                    if ([alertMessage characterAtIndex:alertMessage.length-1]=='.')
                    {
                        alertMessage = [alertMessage stringByAppendingFormat:@" Also, %@",[ghverify.linesAfterCheck objectAtIndex:i]];
                    }
                    else alertMessage = [alertMessage stringByAppendingFormat:@" %@",[ghverify.linesAfterCheck objectAtIndex:i]];
                }
            }
        }
        if (alertMessage.length>15)
        {
            NSString *add = @"Are you certain you'd like to continue saving?";
            alertMessage = [alertMessage stringByAppendingFormat:@" %@",add];
            alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:alertMessage delegate:self cancelButtonTitle:@"Edit" otherButtonTitles:@"Save", nil];
            [alert show];
            return YES;
        }
    }
    if (textView.text.length>0 && ghhaiku.userIsEditing==NO)
        
    //If it's a new haiku:
        
    {
        ghhaiku.newIndex++;
        [ghhaiku.gayHaiku insertObject:dictToSave atIndex:ghhaiku.newIndex];
    }
    
    //If it's an edited old haiku:
    
    else if (ghhaiku.userIsEditing==YES && textView.text.length>0)
    {
        
//Check this functionality.
        
        [ghhaiku.gayHaiku insertObject:dictToSave atIndex:ghhaiku.newIndex];
        [ghhaiku.gayHaiku removeObjectAtIndex:ghhaiku.newIndex+1];
    
        ghhaiku.userIsEditing=NO;
    }
    
    else if (!textView.text.length>0)
    {
        [self.tabBarController setSelectedIndex:0];
        return YES;
    }
    
    [ghhaiku saveToDocsFolder:@"userHaiku.plist"];
        
    PFObject *haikuObject = [PFObject objectWithClassName:@"TestObject"];
    [haikuObject setObject:textView.text forKey:@"haiku"];
    if (self.nameField.text)
    {
        [haikuObject setObject:self.nameField.text forKey:@"author"];
    }
    NSString *perm;
    if (checkboxChecked)
    {
        perm=@"Yes";
    }
    else
    {
        perm=@"No";
    }
    [haikuObject setObject:perm forKey:@"permission"];
    [haikuObject saveEventually];
    ghhaiku.justComposed=YES;
    [textView removeFromSuperview];
    [self.tabBarController setSelectedIndex:0];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger) buttonIndex
{
    if (buttonIndex == 0)
    {
        [textView becomeFirstResponder];
    }
    else if (buttonIndex == 1)
    {
        bypassSyllableCheck=YES;
        [self saveUserHaiku];
        bypassSyllableCheck=NO;
    }
}

- (IBAction)checkCheckbox
{
    checkboxChecked=!checkboxChecked;
    [self displayButton];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:checkboxChecked forKey:@"checked?"];
    [defaults synchronize];
}

@end
