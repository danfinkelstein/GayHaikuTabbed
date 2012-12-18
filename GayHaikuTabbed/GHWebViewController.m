//
//  GHWebViewController.m
//  Gay Haiku
//
//  Created by Joel Derfner on 12/2/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import "GHWebViewController.h"

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@interface GHWebViewController () <UIWebViewDelegate>

@end

@implementation GHWebViewController

@synthesize webV;
@synthesize bar;
@synthesize navBarTitle;
@synthesize alert;
@synthesize indicator;
@synthesize timer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //create nav bar
    [self loadNavBar:@"Buy"];
    
//What does this next line actually do?
    
    //self.navBarTitle.hidesBackButton=YES;
    //should this next line be put into a viewWillAppear method?
    [self seeNavBar];
    
    //Create UIWebView.
    if (!self.webV)
    {
        self.webV = [[UIWebView alloc] init];
    }
    self.webV.delegate = self;
    
    //Load Amazon page.
    
    NSString *baseURLString = @"http://www.amazon.com/Books-by-Joel-Derfner/lm/RVZNXKV59PL51/ref=cm_lm_byauthor_full";
    NSString *urlString = [baseURLString stringByAppendingPathComponent:@"http://www.amazon.com/Books-by-Joel-Derfner/lm/RVZNXKV59PL51/ref=cm_lm_byauthor_full"];
    [self connectWithURL:urlString andBaseURLString:baseURLString];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    //start animating

//But this never starts animating.  Or if it does it animates invisibly.  Why?  What's wrong?
    
    if (!self.indicator)
    {
    self.indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        [self.indicator setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2)];
	[self.indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicator.color=[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:.75];
    }
	[self.view addSubview:self.indicator];
	
    [self.indicator startAnimating];
    NSLog(@"%d",[self.indicator isAnimating]);
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    //Set up and display the navigation bar for the webview.
    NSMutableArray *rightButtons = [[NSMutableArray alloc] init];
    NSMutableArray *leftButtons = [[NSMutableArray alloc] init];
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:NSSelectorFromString(@"webRefresh")];
    UIBarButtonItem *stop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:NSSelectorFromString(@"webStop")];
    [rightButtons addObject:stop];
    [rightButtons addObject:refresh];
    [self.bar removeFromSuperview];
    [self loadNavBar:@"Buy"];
    self.navBarTitle.rightBarButtonItems=rightButtons;
    self.navBarTitle.hidesBackButton=YES;
    if (self.webV.canGoBack)
    {
        UIBarButtonItem *backButt = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webBack.png"] style:UIBarButtonItemStyleBordered target:self action:NSSelectorFromString(@"webBack")];
        [leftButtons addObject:backButt];
    }
    if (self.webV.canGoForward)
    {
        UIBarButtonItem *forwardButt = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webForward.png"] style:UIBarButtonItemStyleBordered target:self action:NSSelectorFromString(@"webForward")];
        [leftButtons addObject:forwardButt];
    }
    self.navBarTitle.leftBarButtonItems=leftButtons;
    [self.indicator stopAnimating];
    [self seeNavBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Create navigation functionality for the UIWebView.

//Allow the user to go to the previous web page.
-(void)webBack
{
    [self.webV goBack];
}

//Allow the user to follow a link.
-(void)webForward
{
    [self.webV goForward];
}

//Refreshes the current web page.
-(void)webRefresh
{
    [self.webV reload];
}

//Interrupts loading the current web page.
-(void)webStop
{
    [self.webV stopLoading];
}

-(void)loadNavBar:(NSString *)t
{
    [self.bar removeFromSuperview];
    self.bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44)];
    self.navBarTitle = [[UINavigationItem alloc] initWithTitle:t];
}

-(void)seeNavBar
{
    [self.bar pushNavigationItem:self.navBarTitle animated:YES];
    [self.bar setTintColor:[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:.75]];
    [self.view addSubview:self.bar];
}

//Sets up and displays error message in case of failure to connect.
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)req navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType==UIWebViewNavigationTypeLinkClicked)
    {
        NSURL *scriptUrl = [NSURL URLWithString:@"http://www.google.com"];
        NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
        if (data == nil)
        {
            [self.indicator stopAnimating];
            self.alert = [[UIAlertView alloc] initWithTitle:@"I'm so sorry!" message:@"Unfortunately, I seem to be having a hard time connecting to the Internet.  Would you mind trying again later?  I promise to make it worth your while." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [self.alert show];
        }
    }
    return YES;
}

-(void)alertViewCancel:(UIAlertView *)alertView
{
    [self.tabBarController setSelectedIndex:0];
}

//Connect to the Internet.
-(void)connectWithURL:(NSString *)us andBaseURLString:(NSString *)bus
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:us] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval: 10];
    NSURLConnection *connectio = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connectio)
    {
        [self.webV loadRequest:request];
    }
    self.webV.scalesPageToFit=YES;
    [self.webV setFrame:(CGRectMake(0,44,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height-64))];
    [self.view addSubview:self.webV];
}

//What to do in case of failure to connect.
-(BOOL)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.alert = [[UIAlertView alloc] initWithTitle:@"I'm so sorry!" message:@"Unfortunately, I seem to be having a hard time connecting to the Internet.  Would you mind trying again later?  I promise to make it worth your while." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [self.alert show];
    return YES;
}

@end
