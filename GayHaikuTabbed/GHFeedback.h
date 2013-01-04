//
//  GHFeedback.h
//  Gay Haiku
//
//  Created by Joel Derfner on 12/2/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHHaiku.h"

@interface GHFeedback : UIViewController {
    GHHaiku *ghhaiku;
    IBOutlet UITextView *feedback;
}

@end
