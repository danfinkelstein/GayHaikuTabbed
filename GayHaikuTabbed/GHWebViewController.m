//
//  GHWebViewController.m
//  Gay Haiku
//
//  Created by Joel Derfner on 12/2/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import "GHWebViewController.h"
#import "GHAppDefaults.h"

@interface GHWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UIWebView *webV;
@property (nonatomic, strong) UIToolbar *bar;
@property (nonatomic, strong) GHAppDefaults *userInfo;

@end

@implementation GHWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
                //Load nav bar
    
    [self loadBar];
    [self seeBar];
    screenHeight = self.view.bounds.size.height;
    screenWidth = self.view.bounds.size.width;
    
                //Create UIWebView.
    
    if (!self.webV) {
        self.webV = [[UIWebView alloc] init];
        self.webV.scalesPageToFit=YES;
        self.webV.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        //webV.autoresizingMask=UIViewAutoresizingFlexibleHeight;
    }
    self.webV.delegate = self;
    
                //Load Amazon page.
    
    NSString *baseURLString = @"http://www.amazon.com/Books-by-Joel-Derfner/lm/RVZNXKV59PL51/ref=cm_lm_byauthor_full";
    NSString *urlString = [baseURLString stringByAppendingPathComponent:@"http://www.amazon.com/Books-by-Joel-Derfner/lm/RVZNXKV59PL51/ref=cm_lm_byauthor_full"];
    [self connectWithURL:urlString andBaseURLString:baseURLString];
    self.userInfo = [GHAppDefaults sharedInstance];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutForInterfaceOrientation:toInterfaceOrientation];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
                //Adds activity indicator to screen and starts animating it
    
    if (!self.indicator) {
        self.indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, ACTIVITY_VIEWER_DIMENSION, ACTIVITY_VIEWER_DIMENSION)];
        [self.indicator setCenter:CGPointMake(screenWidth/2, screenHeight/2)];
        [self.indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.indicator.color=self.userInfo.screenColorTrans;
    }
	[self.view addSubview:self.indicator];
    [self.indicator startAnimating];
    [self createToolbarWithButton:@"webStop"];
}

-(void)createToolbarWithButton: (NSString *)title {
    
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    
                //Create navigation buttons for the right (stop and refresh).
    
    UIBarButtonItem *variable;
    
    if ([title isEqualToString:@"webRefresh"]) {
        variable = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:NSSelectorFromString(title)];
    }
    else {
        variable = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:NSSelectorFromString(title)];
    }
    variable.style = UIBarButtonItemStyleBordered;
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:Nil];
    
    //Load the nav bar.
    
    [self loadBar];
    self.bar.autoresizingMask=UIViewAutoresizingFlexibleWidth;
      
    //Create whatever left buttons are appropriate and add to the arrays.
    
    UIBarButtonItem *backButt = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webBack.png"] style:UIBarButtonItemStylePlain target:self action:NSSelectorFromString(@"webBack")];
    UIBarButtonItem *forButt = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webForward.png"] style:UIBarButtonItemStylePlain target:self action:NSSelectorFromString(@"webForward")];
    backButt.tintColor = self.userInfo.screenColorTrans;
    forButt.tintColor = self.userInfo.screenColorTrans;
    if (self.webV.canGoBack) {
        backButt.style = UIBarButtonItemStyleBordered;
    }
    if (self.webV.canGoForward) {
        forButt.style = UIBarButtonItemStyleBordered;
    }
    
    //Add the left buttons to the nav bar.
    
    [buttons addObject:backButt];
    [buttons addObject:forButt];
    [buttons addObject:flex];
    [buttons addObject:variable];
        
    //Add the right buttons to the nav bar.
    
    self.bar.items=buttons;
    self.bar.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    
    [self seeBar];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    
                //Create the arrays to hold navigation buttons.
    
    [self.indicator stopAnimating];
    [self createToolbarWithButton:@"webRefresh"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webBack {
    
                //Allow the user to go to the previous web page.
    
    [self.webV goBack];
}

-(void)webForward {
    
                //Allow the user to follow a link.
    
    [self.webV goForward];
}

-(void)webRefresh {
    
                //Refreshes the current web page.
    
    [self createToolbarWithButton:@"webStop"];
    [self.webV reload];

}

-(void)webStop {
    
                //Interrupts loading the current web page.
    
    [self createToolbarWithButton:@"webRefresh"];
    [self.webV stopLoading];
    [self.indicator stopAnimating];
}

-(void)loadBar {
    
                //Creates a nav bar.
    
    [self.bar removeFromSuperview];
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        self.bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screenHeight, SHORT_TOOLBAR_HEIGHT)];
    }
    else self.bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, TOOLBAR_HEIGHT)];
    self.bar.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    self.bar.autoresizingMask=UIViewAutoresizingFlexibleHeight;
}

-(void)seeBar {
    
                //Adds the nav bar to the screen.
    
    [self.bar setTintColor:self.userInfo.screenColorTrans];
    self.bar.translucent=YES;
    [self.view addSubview:self.bar];
}

- (void) layoutForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
                // Adjust the toolbar height depending on the screen orientation
    
    CGSize toolbarSize = [self.bar sizeThatFits:self.view.bounds.size];
    self.bar.frame = CGRectMake(0, 0, toolbarSize.width, toolbarSize.height);
    self.webV.frame = CGRectMake(0, toolbarSize.height, toolbarSize.width, self.view.bounds.size.height-toolbarSize.height);
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    
                //Sets up and displays error message in case of failure to connect.
    
    if (navigationType==UIWebViewNavigationTypeLinkClicked) {
        NSURL *scriptUrl = [NSURL URLWithString:@"http://www.google.com"];
        NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
        if (data == nil) {
            [self.indicator stopAnimating];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"I'm sorry." message:@"Unfortunately, this iPhone is having a hard time connecting to the Internet.  Please do try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    return YES;
}

-(void)alertViewCancel:(UIAlertView *)alertView {
    
                //Returns user to home screen upon user okay of same in case of failure to connect.
    
    [self.tabBarController setSelectedIndex:0];
}

-(void)connectWithURL:(NSString *)us andBaseURLString:(NSString *)bus {
    
                //Connect to the Internet.
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:us] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval: 10];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) {
        [self.webV loadRequest:request];
    }
    self.webV.scalesPageToFit=YES;
    [self.webV setFrame:(CGRectMake(0,TOOLBAR_HEIGHT,screenWidth,screenHeight-TAB_BAR_HEIGHT))];
    [self.view addSubview:self.webV];
}

-(BOOL)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
                //What to do in case of failure to connect.
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"I'm sorry." message:@"Unfortunately, this iPhone is having a hard time connecting to the Internet.  Please do try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    return YES;
}

@end
