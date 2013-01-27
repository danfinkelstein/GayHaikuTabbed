//
//  GHWebViewController.h
//  Gay Haiku
//
//  Created by Joel Derfner on 12/2/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GHWebViewController : UIViewController {
    UIActivityIndicatorView *indicator;
    UIToolbar *bar;
    UINavigationItem *navBarTitle;
    UIAlertView *alert;
    UIWebView *webV;
    UIColor *screenColor;
}

@end
