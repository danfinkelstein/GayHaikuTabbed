//
//  GHWebViewController.h
//  Gay Haiku
//
//  Created by Joel Derfner on 12/2/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GHWebViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, weak) IBOutlet UIWebView *webV;
@property (nonatomic, strong) UINavigationBar *bar;
@property (nonatomic, strong) UINavigationItem *navBarTitle;
@property (nonatomic, strong) UIAlertView *alert;

@end
