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
    screenColor = [UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:.75];
    
                //Load nav bar
    
    [self loadNavBar:@"Buy"];   
    [self seeNavBar];
    screenHeight = self.view.bounds.size.height;
    screenWidth = self.view.bounds.size.width;
    
                //Create UIWebView.
    
    if (!webV)
    {
        webV = [[UIWebView alloc] init];
        webV.scalesPageToFit=YES;
    }
    webV.delegate = self;
    
                //Load Amazon page.
    
    NSString *baseURLString = @"http://www.amazon.com/Books-by-Joel-Derfner/lm/RVZNXKV59PL51/ref=cm_lm_byauthor_full";
    NSString *urlString = [baseURLString stringByAppendingPathComponent:@"http://www.amazon.com/Books-by-Joel-Derfner/lm/RVZNXKV59PL51/ref=cm_lm_byauthor_full"];
    [self connectWithURL:urlString andBaseURLString:baseURLString];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
                //Adds activity indicator to screen and starts animating it
    
    if (!indicator)
    {
        indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
        [indicator setCenter:CGPointMake(screenWidth/2, screenHeight/2)];
        [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.color=screenColor;
    }
	[self.view addSubview:indicator];
    [indicator startAnimating];
    
                //Add buttons with stop-loading button in place of refresh button.
    
    NSMutableArray *leftButtons = [[NSMutableArray alloc] init];
    
                //Create navigation buttons for the right (stop and refresh).
    
    //UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:NSSelectorFromString(@"webRefresh")];
    UIBarButtonItem *stop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:NSSelectorFromString(@"webStop")];
    
                //Load the nav bar.
    
    [bar removeFromSuperview];
    [self loadNavBar:@"Buy"];
    
                //Add the right buttons to the nav bar.
    
    navBarTitle.rightBarButtonItem=stop;
    navBarTitle.hidesBackButton=YES;
    
                //Create whatever left buttons are appropriate and add to the arrays.
    
    UIBarButtonItem *backButt = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webBack.png"] style:UIBarButtonItemStyleBordered target:self action:NSSelectorFromString(@"webBack")];
    UIBarButtonItem *forButt = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webForward.png"] style:UIBarButtonItemStyleBordered target:self action:NSSelectorFromString(@"webForward")];
    if (webV.canGoBack) {
        backButt.tintColor=[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:.75];
    }
    else {
        backButt.tintColor=[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:0.75];
    }
    if (webV.canGoForward) {
        forButt.tintColor=[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:.75];
    }
    else {
        forButt.tintColor=[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:0.75];
    }
    
                //Add the left buttons to the nav bar.
    
    [leftButtons addObject:backButt];
    [leftButtons addObject:forButt];
    navBarTitle.leftBarButtonItems=leftButtons;
    [self seeNavBar];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    
                //Create the arrays to hold navigation buttons.
    
    NSMutableArray *rightButtons = [[NSMutableArray alloc] init];
    NSMutableArray *leftButtons = [[NSMutableArray alloc] init];
    
                //Create navigation buttons for the right (stop and refresh).
    
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:NSSelectorFromString(@"webRefresh")];
    
                //Add them to the right array.
    
    [rightButtons addObject:refresh];
    
                //Load the nav bar.
    
    [bar removeFromSuperview];
    [self loadNavBar:@"Buy"];
    
                //Add the right buttons to the nav bar.
    
    navBarTitle.rightBarButtonItem=refresh;
    navBarTitle.hidesBackButton=YES;
    
                //Create whatever left buttons are appropriate and add to the arrays.
    
    UIBarButtonItem *backButt = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webBack.png"] style:UIBarButtonItemStyleBordered target:self action:NSSelectorFromString(@"webBack")];
    UIBarButtonItem *forButt = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webForward.png"] style:UIBarButtonItemStyleBordered target:self action:NSSelectorFromString(@"webForward")];
    if (webV.canGoBack) {
        backButt.tintColor=[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:.75];
    }
    else {
        backButt.tintColor=[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:0.75];
    }
    if (webV.canGoForward) {
        forButt.tintColor=[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:.75];
    }
    else {
        forButt.tintColor=[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:0.75];
    }
                //Add the left buttons to the nav bar.
    
    [leftButtons addObject:backButt];
    [leftButtons addObject:forButt];
    navBarTitle.leftBarButtonItems=leftButtons;
    
                //Lose the activity indicator.
    
    [indicator stopAnimating];
    
                //Display the nav bar.
    
    [self seeNavBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webBack {
    
                //Allow the user to go to the previous web page.
    
    [webV goBack];
}

-(void)webForward {
    
                //Allow the user to follow a link.
    
    [webV goForward];
}

-(void)webRefresh {
    
                //Refreshes the current web page.
    
    [webV reload];
}

-(void)webStop {
    
                //Interrupts loading the current web page.
    
    [webV stopLoading];
    [indicator stopAnimating];
}

-(void)loadNavBar:(NSString *)t {
    
                //Creates a nav bar.
    
    [bar removeFromSuperview];
    bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, toolbarHeight)];
    navBarTitle = [[UINavigationItem alloc] initWithTitle:t];
}

-(void)seeNavBar {
    
                //Adds the nav bar to the screen.
    
    [bar pushNavigationItem:navBarTitle animated:YES];
    [bar setTintColor:screenColor];
    [self.view addSubview:bar];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)req navigationType:(UIWebViewNavigationType)navigationType {
    
                //Sets up and displays error message in case of failure to connect.
    
    if (navigationType==UIWebViewNavigationTypeLinkClicked) {
        NSURL *scriptUrl = [NSURL URLWithString:@"http://www.google.com"];
        NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
        if (data == nil) {
            [indicator stopAnimating];
            alert = [[UIAlertView alloc] initWithTitle:@"I'm so sorry!" message:@"Unfortunately, I seem to be having a hard time connecting to the Internet.  Would you mind trying again later?  I promise to make it worth your while." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:us] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval: 10];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (conn) {
        [webV loadRequest:req];
    }
    webV.scalesPageToFit=YES;
    [webV setFrame:(CGRectMake(0,toolbarHeight,screenWidth,screenHeight-tabBarHeight))];
    [self.view addSubview:webV];
}

-(BOOL)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
                //What to do in case of failure to connect.
    
    alert = [[UIAlertView alloc] initWithTitle:@"I'm so sorry!" message:@"Unfortunately, I seem to be having a hard time connecting to the Internet.  Would you mind trying again later?  I promise to make it worth your while." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    return YES;
}

@end
