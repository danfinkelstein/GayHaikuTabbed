//
//  GHApplication.m
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 12/12/12.
//  Copyright (c) 2012 Joel Derfner. All rights reserved.
//

#import "GHApplication.h"

@interface MyApplication : UIApplication {
    
}

@end

@implementation MyApplication

//This method (really, this class) is designed to allow dataDetectionTypeLink in GHFeedback.m to add a subject line to an email sent to joel@joelderfner.com.

-(BOOL)openURL:(NSURL *)url{
    //if  ([self.delegate openURL:url])
        //return YES;
    //else
        return [super openURL:url];
}
@end
