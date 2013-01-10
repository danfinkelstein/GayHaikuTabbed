//
//  GHWebViewController.m
//  Gay Haiku
//
//  Created by Joel Derfner on 12/2/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import "GHWebViewController.h"
#import "GHConstants.h"

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
    
                //Load nav bar
    
    [self loadNavBar:@"Buy"];   
    [self seeNavBar];
    
                //Create UIWebView.
    
    if (!webV)
    {
        webV = [[UIWebView alloc] init];
    }
    webV.delegate = self;
    
                //Load Amazon page.
    
    NSString *baseURLString = @"http://www.amazon.com/Books-by-Joel-Derfner/lm/RVZNXKV59PL51/ref=cm_lm_byauthor_full";
    NSString *urlString = [baseURLString stringByAppendingPathComponent:@"http://www.amazon.com/Books-by-Joel-Derfner/lm/RVZNXKV59PL51/ref=cm_lm_byauthor_full"];
    [self connectWithURL:urlString andBaseURLString:baseURLString];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    if (!indicator)
    {
        indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        [indicator setCenter:CGPointMake(screenWidth/2, [[UIScreen mainScreen] bounds].size.height/2)];
        [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.color=[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:.75];
    }
	[self.view addSubview:indicator];
	
    [indicator startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    
                //Set up and display the navigation bar for the webview.
    
    NSMutableArray *rightButtons = [[NSMutableArray alloc] init];
    NSMutableArray *leftButtons = [[NSMutableArray alloc] init];
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:NSSelectorFromString(@"webRefresh")];
    UIBarButtonItem *stop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:NSSelectorFromString(@"webStop")];
    [rightButtons addObject:stop];
    [rightButtons addObject:refresh];
    [bar removeFromSuperview];
    [self loadNavBar:@"Buy"];
    navBarTitle.rightBarButtonItems=rightButtons;
    navBarTitle.hidesBackButton=YES;
    if (webV.canGoBack) {
        UIBarButtonItem *backButt = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webBack.png"] style:UIBarButtonItemStyleBordered target:self action:NSSelectorFromString(@"webBack")];
        [leftButtons addObject:backButt];
    }
    if (webV.canGoForward) {
        UIBarButtonItem *forButt = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webForward.png"] style:UIBarButtonItemStyleBordered target:self action:NSSelectorFromString(@"webForward")];
        [leftButtons addObject:forButt];
    }
    navBarTitle.leftBarButtonItems=leftButtons;
    [indicator stopAnimating];
    [self seeNavBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Create navigation functionality for the UIWebView.

//Allow the user to go to the previous web page.
-(void)webBack {
    [webV goBack];
}

//Allow the user to follow a link.
-(void)webForward {
    [webV goForward];
}

//Refreshes the current web page.
-(void)webRefresh {
    [webV reload];
}

//Interrupts loading the current web page.
-(void)webStop {
    [webV stopLoading];
}

-(void)loadNavBar:(NSString *)t {
    [bar removeFromSuperview];
    bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, toolbarHeight)];
    navBarTitle = [[UINavigationItem alloc] initWithTitle:t];
}

-(void)seeNavBar {
    [bar pushNavigationItem:navBarTitle animated:YES];
    [bar setTintColor:[UIColor colorWithRed:123/255.0 green:47/255.0 blue:85/255.0 alpha:.75]];
    [self.view addSubview:bar];
}

//Sets up and displays error message in case of failure to connect.
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)req navigationType:(UIWebViewNavigationType)navigationType {
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
    [webV setFrame:(CGRectMake(0,toolbarHeight,screenWidth,[[UIScreen mainScreen] bounds].size.height-tabBarHeight))]; 
    [self.view addSubview:webV];
}

-(BOOL)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
                //What to do in case of failure to connect.
    
    alert = [[UIAlertView alloc] initWithTitle:@"I'm so sorry!" message:@"Unfortunately, I seem to be having a hard time connecting to the Internet.  Would you mind trying again later?  I promise to make it worth your while." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    return YES;
}

@end
