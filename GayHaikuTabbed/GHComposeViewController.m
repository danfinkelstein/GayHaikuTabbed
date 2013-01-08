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

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //Create and add swipe gesture recognizers
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(displayComposeScreen)];
    swipeRight.numberOfTouchesRequired = 1;
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(displayInstructionsScreen)];
    swipeLeft.numberOfTouchesRequired = 1;
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    userSettings = [GHUserSettings sharedInstance];
    [userSettings setUserDefaults];
    animateComposeScreen=NO;
    
    bypassSyllableCheck=NO;
    
    if (!ghhaiku)
    {
        ghhaiku = [GHHaiku sharedInstance];
    }
    
    //Load background image.
    
    CGRect frame;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (screenHeight<500) {
        frame = CGRectMake(0, 0, 320, (480-49));
    }
    else {
        frame = CGRectMake(0, 0, 320, (568-49));
    }
    background = [[UIImageView alloc] initWithFrame:frame];
    if (screenHeight<500) {
        background.image=[UIImage imageNamed:@"temp background.jpg"];
    }
    else {
        background.image=[UIImage imageNamed:@"iPhone5 temp background.jpg"];
    }
    [self.view addSubview:background];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (userSettings.optOutSeen==NO) { //If the user hasn't ever seen the opt out screen, show it.
        [self.tabBarController setSelectedIndex:4];
    }
    else if (userSettings.instructionsSeen==NO) { //If the user hasn't ever seen instructions screen, show it.
        animateComposeScreen=YES;
        [self displayInstructionsScreen];
    }
    else { //Show the compose screen.
        animateComposeScreen=NO;
        [self displayComposeScreen];
    }
}



-(UITextView *)createSwipeToAdd { //Create the text "swipe" to let the user know there's a previous/next screen.
    UITextView *showSwipeInstructions = [[UITextView alloc] init];
    showSwipeInstructions.editable=NO;
    showSwipeInstructions.textColor = [UIColor purpleColor];
    showSwipeInstructions.backgroundColor = [UIColor clearColor];
    if (userSettings.instructionsSeen==NO) {
        showSwipeInstructions.text = @"Next";
    }
    else {
        showSwipeInstructions.text = @"Swipe to compose";
    }
    showSwipeInstructions.font = [UIFont fontWithName:@"Zapfino" size:14];
    return showSwipeInstructions;
}

-(void)addSwipeForRight:(NSString *)direction
//Adds the text telling the user to swipe right to continue.
{
    
    //Create the text to tell the user to swipe to the next screen.
    
    nextInstructions = [self createSwipeToAdd];
    
    //Locate and frame the text on the right side of the view.
    
    CGSize dimensions = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 400); //Why did I choose 400?
    CGSize xySize = [nextInstructions.text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:14] constrainedToSize:dimensions lineBreakMode:0];
    CGRect rect = CGRectMake((dimensions.width - xySize.width-30), [[UIScreen mainScreen] bounds].size.height-180, xySize.width*1.5, (xySize.height*2));
    nextInstructions.frame = rect;
        
    //Display it.
    
    [self animateView:nextInstructions withDirection:direction];
    [self.view addSubview:nextInstructions];
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

/*-(void)keyboardWillShow:(NSNotification *)aNotification
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
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)displayComposeScreen
{  
    //Hide the instructions.
    instructions.hidden=YES;
    [nextInstructions removeFromSuperview];
    
    //Create the textView if it doesn't exist.
    if (!textView) {
        textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, 280, 180)];
        textView.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        textView.delegate = self;
    }
    
    [self addTranslucentToolbarAboveKeyboard];
    
    //Set the textView's attributes and delegate.
    textView.editable=YES;
    textView.backgroundColor = [UIColor colorWithRed:216/255.0 green:121/255.0 blue:158/255.0 alpha:1];
    textView.hidden=NO;
    
    //If the user is NOT editing a user haiku, or if it's not a user haiku, set the textView's text to nil.  If the user IS editing a user haiku, set the textView's text to that haiku.
    if (ghhaiku.userIsEditing==NO || ghhaiku.isUserHaiku==NO) {
        textView.text = @"";
    }
    else {
        textView.text = ghhaiku.text;
    }
    
    //Show the textView and set up the keyboard.
    [self.view addSubview:textView];
    [textView becomeFirstResponder];

    
//Set the compose screen's background (to come with graphic)
    
    //Keyboard height is 216, so UIImageView is 264 high for iPhone4, 352 high for iPhone5
    //screen=0;
    
//IF AND ONLY IF USER IS COMING FROM INSTRUCTIONS!
    if (animateComposeScreen == YES) {
        [self animateView:self.view withDirection:@"right"];
        animateComposeScreen=NO;
    }
}

-(void)addTranslucentToolbarAboveKeyboard {
    
    //Create translucent toolbar to sit above keyboard.
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setTintColor:[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:.75]];
    [toolbar sizeToFit];
    
    //Create "instructions" and "done" buttons and add them to the translucent toolbar.
    UIBarButtonItem *instructionsButton = [[UIBarButtonItem alloc] initWithTitle:@"Instructions" style:UIBarButtonItemStyleBordered target:self action:@selector(displayInstructionsScreen)];
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

-(void)displayInstructionsScreen {
    
    //In case user is coming from the compose screen, which has a different background image, set the background image for the screen.
    CGRect frame;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (screenHeight<500) {
        frame = CGRectMake(0, 0, 320, (480-49));
    }
    else {
        frame = CGRectMake(0, 0, 320, (568-49));
    }
    background = [[UIImageView alloc] initWithFrame:frame];
    if (screenHeight<500) {
        background.image=[UIImage imageNamed:@"temp background.jpg"];
    }
    else {
        background.image=[UIImage imageNamed:@"iPhone5 temp background.jpg"];
    }
    [self.view addSubview:background];
    
    //Hide the appropriate views.
    textView.hidden=YES;
    [textView resignFirstResponder];
    
    //Create the instructions if they don't exist and set their attributes.
    
    if (!instructions)
    {
        instructions = [[UITextView alloc] init]; 
        instructions.backgroundColor=[UIColor clearColor];
        instructions.text = @"\nFor millennia, the Japanese haiku has allowed great thinkers to express their ideas about the world in three lines of five, seven, and five syllables respectively.  \n\nContrary to popular belief, the three lines need not be three separate sentences.  Rather, either the first two lines are one thought and the third is another or the first line is one thought and the last two are another; the two thoughts are often separated by punctuation.\n\nHave a fabulous time composing your own gay haiku!";
        CGSize dimensions = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 400);

//AGAIN, WHY DID I PICK 400?
        
        CGSize xySize = [instructions.text sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:12] constrainedToSize:dimensions lineBreakMode:0];
        instructions.frame = CGRectMake(10, ([[UIScreen mainScreen] bounds].size.height/2) - xySize.height/2 - 20, [[UIScreen mainScreen] bounds].size.width - 10, [[UIScreen mainScreen] bounds].size.height);
        instructions.editable=NO;
    }
    if (userSettings.instructionsSwipedToFromOptOut==YES) { //If we're coming from the opt-out screen, animate instructions from left.
        [self animateView:instructions withDirection:@"left"];
        [self addSwipeForRight:@"left"];
    }
    else if (userSettings.instructionsSwipedToFromOptOut==NO) { //If we're coming from the compose screen, animate instructions from right.
        [self animateView:instructions withDirection:@"right"];
        [self addSwipeForRight:@"right"];
    }
    userSettings.instructionsSwipedToFromOptOut=YES;
    [userSettings.defaults setBool:YES forKey:@"instructionsSwipedTo?"];
    [userSettings.defaults synchronize];

    if (userSettings.instructionsSeen==NO) {
        userSettings.instructionsSeen=YES;
        [userSettings.defaults setBool:YES forKey:@"instructionsSeen?"];
        [userSettings.defaults synchronize];
    }
    instructions.hidden=NO;
    animateComposeScreen=YES;
    [self.view addSubview:instructions];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)doActionSheet
{
    [textView resignFirstResponder];
    UIActionSheet *actSheet;
    
    //If user is editing a haiku that already exists
    if (ghhaiku.userIsEditing) {
        
        //If user hasn't made any changes, simply return to home screen and current haiku.
        if ([textView.text isEqualToString: ghhaiku.text]) {
            textView.text=@"";
            [self.tabBarController setSelectedIndex:0];
        }
        
        //If user has made changes, show action sheet with options to save/edit/discard.
        else {
            actSheet = [[UIActionSheet alloc] initWithTitle:nil delegate: self cancelButtonTitle:@"Continue Editing" destructiveButtonTitle:@"Discard Changes" otherButtonTitles:@"Save", nil];
            [actSheet showFromTabBar:self.tabBarController.tabBar];
        }
    }
    
    //If this is a new haiku
    else {
        
        //If user has composed nothing, simply return to home screen and current haiku.
        if (textView.text.length==0) {
            textView.text=@"";
            [self.tabBarController setSelectedIndex:0];
        }
        
        //If user has composed something, show the action sheet.
        else {
        actSheet = [[UIActionSheet alloc] initWithTitle:nil delegate: self cancelButtonTitle:@"Continue Editing" destructiveButtonTitle:@"Discard" otherButtonTitles:@"Save", nil];
        [actSheet showFromTabBar:self.tabBarController.tabBar];         }
    }
}

-(void)actionSheet:(UIActionSheet *)actSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==0) {
        textView.text=@"";
        [self.tabBarController setSelectedIndex:0];
    }
    else if (buttonIndex==1) {
        [self saveUserHaiku];
    }
    else {
        [actSheet dismissWithClickedButtonIndex:2 animated:YES];
        [textView becomeFirstResponder];
    }
}

-(void)verifySyllables {
    
    //Create an instance of GHVerify if one doesn't exist.
    if (!ghverify) {
        ghverify = [[GHVerify alloc] init];
    }
    
    //Divide the current haiku into lines.
    [ghverify splitHaikuIntoLines:textView.text];
    
    //Check the number of syllables in each line.
    [ghverify checkHaikuSyllables];
    
    NSString *alertMessage=@"I'm sorry, but ";

    if (ghverify.numberOfLinesAsProperty==0) {
        alertMessage = [alertMessage stringByAppendingString:@"your haiku seems to have too few lines."];
    }
    else if (ghverify.numberOfLinesAsProperty==2) {
        alertMessage = [alertMessage stringByAppendingString:@"your haiku seems to have too many lines."];
    }
    int k;
    if (ghverify.listOfLines.count<3) {
        k=ghverify.listOfLines.count;
    }
    else {
        k=3;
    }
    NSMutableArray *arrayOfLinesToAlert = [[NSMutableArray alloc] init];
    for (int i=0; i<k; i++) {
        if ([ghverify.linesAfterCheck objectAtIndex:i])
        {
            if (![[ghverify.linesAfterCheck objectAtIndex:i] isEqualToString:@"just right"]) {
                [arrayOfLinesToAlert addObject:[NSNumber numberWithInt:i+1].stringValue];
            }
        }
    }
    if (arrayOfLinesToAlert.count>0) {
        NSString *phrase;
        NSString *number;
        if (arrayOfLinesToAlert.count==1) {
            number = [NSString stringWithFormat:@"line %@",[arrayOfLinesToAlert objectAtIndex:0] ];
        }
        else if (arrayOfLinesToAlert.count==2) {
            number = [NSString stringWithFormat:@"lines %@ and %@",[arrayOfLinesToAlert objectAtIndex:0],[arrayOfLinesToAlert objectAtIndex:1]];
            }
        else if (arrayOfLinesToAlert.count==3) {
            number = [NSString stringWithFormat:@"lines %@, %@, and %@",[arrayOfLinesToAlert objectAtIndex:0],[arrayOfLinesToAlert objectAtIndex:1],[arrayOfLinesToAlert objectAtIndex:2]];
        }
        phrase = [NSString stringWithFormat:@"%@ might have the wrong number of syllables. You need 5-7-5. ",number];
        if ([alertMessage characterAtIndex:alertMessage.length-1]=='.') {
                alertMessage = [alertMessage stringByAppendingFormat:@" Also, %@",phrase];
            }
        else alertMessage = [alertMessage stringByAppendingFormat:@"%@",phrase];
        }
    
    arrayOfLinesToAlert=Nil;
    if (alertMessage.length>15) {
        NSString *add = @"Are you certain you'd like to continue saving?";
        alertMessage = [alertMessage stringByAppendingFormat:@" %@",add];
        alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:alertMessage delegate:self cancelButtonTitle:@"Edit" otherButtonTitles:@"Save", nil];
        [alert show];
    }
}

-(BOOL)saveUserHaiku
{
    //This makes sure the new haiku isn't a repeat of a haiku that's already in the database.  If it is, this dismisses the compose screen and puts the haiku already in the database on the main screen.
    int i;
    for (i=0; i<ghhaiku.gayHaiku.count; i++) {
        NSString *haikuToCheck = [[ghhaiku.gayHaiku objectAtIndex:i] valueForKey:@"haiku"];
        if ([textView.text isEqualToString:haikuToCheck]) {
            //Even though a new haiku has not been composed, this will display the version of the haiku already in the database.
            ghhaiku.justComposed=YES;
            ghhaiku.newIndex = i;
            [self.tabBarController setSelectedIndex:0];
            return YES;
        }
    }
    
    //This checks to make sure the syllable counts are correct.
    
    if (bypassSyllableCheck==NO) {
        [self verifySyllables];
//Check this next line--shouldn't function continue after syllables are verified if they're verified yes?
        return YES;
    }
    
    //This creates the dictionary item of the new haiku to save in userHaiku.plist.
    NSString *textWithAttribution;
    if (userSettings.author) {
        //Add the user's name to the haiku
        textWithAttribution = [textView.text stringByAppendingFormat:@"\n\n\t\t%@",userSettings.author];
    }
    else {
        textWithAttribution = textView.text;
    }
    NSArray *collectionOfHaiku = [[NSArray alloc] initWithObjects:@"user", textWithAttribution, nil];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"category",@"haiku",nil];
    NSDictionary *dictToSave = [[NSDictionary alloc] initWithObjects:collectionOfHaiku forKeys:keys];

    if (textView.text.length>0 && ghhaiku.userIsEditing==NO) {
        
    //If it's a new haiku:
        
        ghhaiku.newIndex++;
        [ghhaiku.gayHaiku insertObject:dictToSave atIndex:ghhaiku.newIndex];
    }
    
    //If it's an edited old haiku:
    
    else if (ghhaiku.userIsEditing==YES && textView.text.length>0)
    {
        
        [ghhaiku.gayHaiku insertObject:dictToSave atIndex:ghhaiku.newIndex];
        [ghhaiku.gayHaiku removeObjectAtIndex:ghhaiku.newIndex+1];
    
        ghhaiku.userIsEditing=NO;
    }
    
    else if (!textView.text.length>0) {
        [self.tabBarController setSelectedIndex:0];
        return YES;
    }
    
    [ghhaiku saveToDocsFolder:@"userHaiku.plist"];
    
    PFObject *haikuObject = [PFObject objectWithClassName:@"TestObject"];
    [haikuObject setObject:textView.text forKey:@"haiku"];
    NSString *perm;
    if (userSettings.checkboxChecked) {
        perm=@"Yes";
    }
    else {
        perm=@"No";
    }
    [haikuObject setObject:perm forKey:@"permission"];
    [haikuObject saveEventually];
    ghhaiku.justComposed=YES;
    [textView removeFromSuperview];
    [self.tabBarController setSelectedIndex:0];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger) buttonIndex {
    if (buttonIndex == 0) {
        [textView becomeFirstResponder];
    }
    else if (buttonIndex == 1) {
        bypassSyllableCheck=YES;
        [self saveUserHaiku];
        bypassSyllableCheck=NO;
    }
}

@end
