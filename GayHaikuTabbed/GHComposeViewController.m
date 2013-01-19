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
    
                //Set defaults, including user defaults, non-animated compose screen, and syllable check activated.
    
    userSettings = [GHAppDefaults sharedInstance];
    [userSettings setUserDefaults];
    animateComposeScreen=NO;
    
                //Access the shared instance of GHHaiku.

    ghhaiku = [GHHaiku sharedInstance];
    
                //Add the background image, choosing the correct one depending on whether you're using a 3.5 or a 4-inch screen.
    
    screenHeight = self.view.bounds.size.height;
    screenWidth = self.view.bounds.size.width;
    frame = CGRectMake(0, 0, screenWidth, (screenHeight-tabBarHeight));
    background = [[UIImageView alloc] initWithFrame:frame];
    [self.view addSubview:background];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
                //If the user hasn't ever seen the opt out screen, show it.

    if (userSettings.optOutSeen==NO) { 
        [self.tabBarController setSelectedIndex:4];
    }
    
                //Otherwise, if the user hasn't ever seen instructions screen, show it.
    
    else if (userSettings.instructionsSeen==NO) { 
        [self displayInstructionsScreen];
        
                //Indicate that, since we're on instructions screen, if we go to the compose screen it should animate.
        
        animateComposeScreen=YES;
    }
    
                //Otherwise, show the compose screen.  Indicate we're NOT coming from instructions screen so that compose screen won't be animated.
    
    else { 
        animateComposeScreen=NO;
        [self displayComposeScreen];
    }
}

-(UITextView *)createSwipeToAdd: (NSString *)word {
    
                //Create "Swipe" text and its characteristics
    
    UITextView *baba = [[UITextView alloc] init];
    baba.editable=NO;
    baba.userInteractionEnabled=NO;
    baba.textColor = [UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:1];
    baba.backgroundColor = [UIColor clearColor];
    baba.text = word;
    baba.font = [UIFont fontWithName:@"Zapfino" size:largeFontSize];
    return baba;
}

-(void)addSwipeForRight:(NSString *)direction {

                //Create the text to tell the user to swipe to the next screen.
    
    NSString *word;
    if (userSettings.instructionsSeen==NO) {
        word = @"Next";
    }
    else {
        word = @"Swipe to compose";
    }
    nextInstructions = [self createSwipeToAdd:word];
    NSString *text = [word stringByAppendingString:@"compo"];
    
                //Locate and frame the text on the right side of the view.
    CGSize xySize;
    CGRect rect;
    xySize = [text sizeWithFont:[UIFont fontWithName:@"Zapfino" size:largeFontSize]];
    rect = CGRectMake((screenWidth - xySize.width), screenHeight*0.625, xySize.width, xySize.height);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {

    }
    else {
        if (self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
            
        }
        else {
            
        }
    }
    nextInstructions.frame = rect;
        
                //Display and animate it.
    
    [self animateView:nextInstructions withDirection:direction];
    [self.view addSubview:nextInstructions];
}

-(void)animateView:(UIView *)tv withDirection: (NSString *)direction {
    
                //Set animation.
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.delegate = self;
    
                //Indicate which direction animation is going.
    
    if (direction==@"right") transition.subtype =kCATransitionFromRight;
    else if (direction==@"left") transition.subtype = kCATransitionFromLeft;

                //Add animation.
    
    [tv.layer addAnimation:transition forKey:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)displayComposeScreen {
    
                //Change the screen to the compose screen.
    
    [background removeFromSuperview];
    frame = CGRectMake(0, 0, screenWidth, screenHeight);
    background = [[UIImageView alloc] initWithFrame:frame];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (screenHeight<500) {
            background.image=[UIImage imageNamed:@"compose.png"];
        }
        else {
            background.image=[UIImage imageNamed:@"compose.png"];
        }
    }
    else {
        if (self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
            
        }
        else {
            
        }
    }
    [self.view addSubview:background];
    
                //Hide the instructions and the swipe-for-next text.
    
    instructions.hidden=YES;
    [nextInstructions removeFromSuperview];
    
                //Create the textView if it doesn't exist.
    
    if (!textView) {
        if (screenHeight<500) {
            textView = [[UITextView alloc] initWithFrame:CGRectMake(40, 40, 240, 135)];
        }
        else {
            textView = [[UITextView alloc] initWithFrame:CGRectMake(40, 40, 240, 222)];
        }
        textView.font = [UIFont fontWithName:@"Helvetica Neue" size:largeFontSize];
        textView.delegate = self;
    }
    
                //Create the translucent toolbar for above the keyboard.
    
    [self addTranslucentToolbarAboveKeyboard];
    
                //Set the textView's attributes.
    
    textView.editable=YES;
    textView.backgroundColor = [UIColor clearColor];
    textView.hidden=NO;
    
                //If the user is NOT editing a user haiku, set the textView's text to nil.  If the user IS editing a user haiku, set the textView's text to that haiku.
    
    if (ghhaiku.userIsEditing==NO || ghhaiku.isUserHaiku==NO) {
        textView.text = @"";
    }
    else {
        textView.text = ghhaiku.text;
    }
    
                //Show the textView and set up the keyboard.
    
    [self.view addSubview:textView];
    [textView becomeFirstResponder];
    
                //Set up animation if we're coming from the instructions screen and set boolean so we're not coming from the instructions screen anymore.
    
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
    
-(void)resignKeyboard {
    
                //Resign first responder and call action sheet.
    
    [textView resignFirstResponder];
    [self doActionSheet];
}

-(void)displayInstructionsScreen {
    
                //In case user is coming from the compose screen, which has a different background image, set the background image for the screen.
    
    [background removeFromSuperview];
    frame = CGRectMake(0, 0, screenWidth, screenHeight-tabBarHeight);
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
            
        }
        else {
            
        }
    }
    [self.view addSubview:background];
    
                //Hide the textview and resign first responder.
    
    textView.hidden=YES;
    [textView resignFirstResponder];
    
                //Create the instructions if they don't exist and set their attributes.
    
    if (!instructions)
    {
        instructions = [[UITextView alloc] init];
        instructions.backgroundColor=[UIColor clearColor];
        instructions.font = [UIFont fontWithName:@"Helvetica Neue" size:smallFontSize];
        instructions.editable=NO;
        instructions.text = @"\nFor millennia, the Japanese haiku has allowed great\nthinkers to express their ideas about the world in three\nlines of five, seven, and five syllables respectively.\n\nContrary to popular belief, the three lines need not be\nthree separate sentences. Rather, either the first two\nlines are one thought and the third is another or the\nfirst line is one thought and the last two are another;\nthe two thoughts are often separated by punctuation.\n\nHave a fabulous time composing your own gay haiku!";
        NSString *t = @"thinkers to express their ideas about the world in three lin";
        CGSize thisSize = [t sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:smallFontSize]];
        int textWidth = thisSize.width;
        const int INSTRUCTIONS_HEIGHT=17;

//Obviously this is an ugly hack and needs to be defined somewhere else.
        
        int textHeight = thisSize.height*INSTRUCTIONS_HEIGHT;
        instructions.frame = CGRectMake(screenWidth/2-textWidth/2, screenHeight/2-textHeight/2, textWidth, textHeight);
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {

        }
        else {
            if (self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
                
            }
            else {
                
            }
        }
    }
    
                //If we're coming from the opt-out screen (i.e. swiping from the right, animate the instructions to the left.
    
    if (userSettings.instructionsSwipedToFromOptOut==YES) {
        [self animateView:instructions withDirection:@"left"];
        [self addSwipeForRight:@"left"];
    }
    
                //If we're coming from the compose screen (i.e. swiping from the left), animate the instructions to the left. 
    
    else if (userSettings.instructionsSwipedToFromOptOut==NO) { //If we're coming from the compose screen, animate instructions from right.
        [self animateView:instructions withDirection:@"right"];
        [self addSwipeForRight:@"right"];
    }
    
                //Set boolean to indicate that the opt-out to instructions swipe has happened, and update the defaults.
    
    if (userSettings.instructionsSwipedToFromOptOut==NO) {
        userSettings.instructionsSwipedToFromOptOut=YES;
        [userSettings.defaults setBool:YES forKey:@"instructionsSwipedTo?"];
        [userSettings.defaults synchronize];
    }
    
                //Set boolean to indicate that the instructions have been seen, and update the defaults
    
    if (userSettings.instructionsSeen==NO) {
        userSettings.instructionsSeen=YES;
        [userSettings.defaults setBool:YES forKey:@"instructionsSeen?"];
        [userSettings.defaults synchronize];
    }
    
                //If we're coming from the compose screen, make sure the instructions are visible.  Add them to the view.
    
    instructions.hidden=NO;
    [self.view addSubview:instructions];
    
                //Animate the compose screen if that's where we go next.
    
    animateComposeScreen=YES;
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
    
                //If user hasn't made any changes, simply return to home screen and current haiku.
    
    if (textView.text.length==0) {
        textView.text=@"";
        [self.tabBarController setSelectedIndex:0];
    }
    
                //If user HAS made changes, show alert view with appropriate destructive button title depending on whether it's a new haiku or an edited one.
    else {
        NSString *destroyButtonTitle;
        if (ghhaiku.userIsEditing) {
            destroyButtonTitle=@"Discard Changes";
        }
        else {
            destroyButtonTitle=@"Discard";
        }
        actSheet = [[UIActionSheet alloc] initWithTitle:nil delegate: self cancelButtonTitle:@"Continue Editing" destructiveButtonTitle:destroyButtonTitle otherButtonTitles:@"Save", nil];
        [actSheet showFromTabBar:self.tabBarController.tabBar];
    
                //Show appropriate screen.
    
        /*if (screenHeight<500) {
            background.image=[UIImage imageNamed:@"compose.png"];
        }
        else {
            background.image=[UIImage imageNamed:@"5compose.png"];
        }*/
        [actSheet showFromTabBar:self.tabBarController.tabBar];
    }
}

-(void)actionSheet:(UIActionSheet *)actSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
                //If the action sheet button is "cancel" or "discard changes," return to the home screen.
    
    if (buttonIndex==0) {
        textView.text=@"";
        [self.tabBarController setSelectedIndex:0];
    }
    
                //If the action sheet button is "save," save the haiku.
    
    else if (buttonIndex==1) {
        [self verifySyllables];
    }
    
                //If the action sheet button is "continue editing," dismiss action sheet and make textView the first responder again.
    
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
    
                //Construct the part of the alert message correcting the number of lines, if one be necessary.
    
    NSString *alertMessage=@"I'm sorry, but ";

    if (ghverify.numberOfLinesAsProperty==tooFewLines) {
        alertMessage = [alertMessage stringByAppendingString:@"your haiku seems to have too few lines."];
    }
    else if (ghverify.numberOfLinesAsProperty==tooManyLines) {
        alertMessage = [alertMessage stringByAppendingString:@"your haiku seems to have too many lines."];
    }
    
                //Create an iterator for the array of lines in the haiku.
    
    int k;
    if (ghverify.listOfLines.count<3) {
        k=ghverify.listOfLines.count;
    }
    else {
        k=3;
    }
    
                //Create an array to hold the record of lines that have an incorrect number of syllables.
    
    NSMutableArray *arrayOfLinesToAlert = [[NSMutableArray alloc] init];
    
                //Iterate through the array of lines in the haiku and, if any need correction, note that in arrayOfLinesToAlert.
    
    for (int i=0; i<k; i++) {
        if ([ghverify.linesAfterCheck objectAtIndex:i])
        {
            if (![[ghverify.linesAfterCheck objectAtIndex:i] isEqualToString:@"just right"]) {
                [arrayOfLinesToAlert addObject:[NSNumber numberWithInt:i+1].stringValue];
            }
        }
    }
    
                //If there are syllable errors, add notification of these to the alert message.
    
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
    
                //If the alert message needs displaying (i.e., if it goes beyond the introductory "I'm sorry" phrase, which is 15 characters long), add an ending to it and display it with an alertView.
    
    if (alertMessage.length>15) {
        NSString *add = @"Are you certain you'd like to continue saving?";
        alertMessage = [alertMessage stringByAppendingFormat:@" %@",add];
        alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:alertMessage delegate:self cancelButtonTitle:@"Edit" otherButtonTitles:@"Save", nil];
        /*if (screenHeight<500) {
            background.image=[UIImage imageNamed:@"compose.png"];
        }
        else {
            background.image=[UIImage imageNamed:@"5compose.png"];
        }*/
        [alert show];
    }
    
                //Otherwise, save the haiku.
    
    else {
        [self saveUserHaiku];
    }
}

-(void)checkForRepeats {
    
                //Check to see whether the haiku the user has written is an exact duplicate of one already in the database.
    
    int i;
    for (i=0; i<ghhaiku.gayHaiku.count; i++) {
        NSString *haikuToCheck = [[ghhaiku.gayHaiku objectAtIndex:i] valueForKey:@"haiku"];
        
                //If it is, set that haiku to be the current haiku and return to the home screen.
        
        if ([textView.text isEqualToString:haikuToCheck]) {
            ghhaiku.justComposed=YES;
            ghhaiku.newIndex = i;
            [self.tabBarController setSelectedIndex:0];
        }
    }
}

-(BOOL)saveUserHaiku
{

                //Get out of this if the haiku is a repeat of one the user has already written.
    
    [self checkForRepeats];
    
                //Add the user's name to the haiku if s/he has entered one.
    
    NSString *textWithAttribution;
    if (userSettings.author) {
        //Add the user's name to the haiku
        textWithAttribution = [textView.text stringByAppendingFormat:@"\n\n\t\t%@",userSettings.author];
    }
    else {
        textWithAttribution = textView.text;
    }
    
                //Create the dictionary item of the new haiku to save in userHaiku.plist.
    
    NSArray *collectionOfHaiku = [[NSArray alloc] initWithObjects:@"user", textWithAttribution, nil];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"category",@"haiku",nil];
    NSDictionary *dictToSave = [[NSDictionary alloc] initWithObjects:collectionOfHaiku forKeys:keys];

                //If the saved haiku is a new haiku, advance the current index by one and insert the new haiku at that position.
    
    if (textView.text.length>0 && ghhaiku.userIsEditing==NO) {
        ghhaiku.newIndex++;
        [ghhaiku.gayHaiku insertObject:dictToSave atIndex:ghhaiku.newIndex];
    }
    
                //If the saved haiku is an edited old haiku, replace the old version with the edited version and indicate that user is no longer editing.
    
    else if (ghhaiku.userIsEditing==YES && textView.text.length>0)
    {
        [ghhaiku.gayHaiku insertObject:dictToSave atIndex:ghhaiku.newIndex];
        [ghhaiku.gayHaiku removeObjectAtIndex:ghhaiku.newIndex+1];
        ghhaiku.userIsEditing=NO;
    }
    
                //If there's no actual haiku, return to the home screen.
    
    else if (!textView.text.length>0) {
        [self.tabBarController setSelectedIndex:0];
        return YES;
    }
    
                //Save the haiku to the plist.
    
    [ghhaiku saveToDocsFolder:@"userHaiku.plist"];
    
                //Create a PFObject to send to parse.com with the text of the haiku
    
    PFObject *haikuObject = [PFObject objectWithClassName:@"TestObject"];
    [haikuObject setObject:textView.text forKey:@"haiku"];
    
                //Include the author's name with the object
    
    if (userSettings.author) {
        [haikuObject setObject:userSettings.author forKey:@"author"];
    }
    
                //Indicate whether I have permission to use it.
    
    NSString *perm;
    if (userSettings.checkboxChecked) {
        perm=@"Yes";
    }
    else {
        perm=@"No";
    }
    [haikuObject setObject:perm forKey:@"permission"];
    
               //Send the PFObject.

    [haikuObject saveEventually];
    
                //Indicate that the current haiku is a user-composed one so the home screen knows what to display.
    
    ghhaiku.justComposed=YES;
    
                //Remove unnecessary UITextViews from view.
    
    [textView removeFromSuperview];
    [nextInstructions removeFromSuperview];
    
                //Return to home screen.
    
    [self.tabBarController setSelectedIndex:0];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger) buttonIndex {
    
                //If there are syllable solecisms and user choice is "continue editing," return to the textView.
    
    if (buttonIndex == 0) {
        [textView becomeFirstResponder];
    }
    
                //Otherwise, save haiku despite solecisms.
    
    else if (buttonIndex == 1) {
        [self saveUserHaiku];
    }
}

@end
