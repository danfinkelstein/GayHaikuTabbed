//
//  GHConstants.m
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 1/8/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import "GHConstants.h"

float const screenWidth = 320;
float const tabBarHeight = 49;
float const toolbarHeight = 44;
float const keyboardHeight = 216;
float const buttonSideLength = 44;

@implementation GHConstants

-(UITextView *)createSwipeToAdd: (NSString *)word {
    
                //Create "Swipe" text and its characteristics
    
    UITextView *instructions = [[UITextView alloc] init];
    instructions.editable=NO;
    instructions.textColor = [UIColor purpleColor];
    instructions.backgroundColor = [UIColor clearColor];
    instructions.text = word;
    instructions.font = [UIFont fontWithName:@"Zapfino" size:17];
    return instructions;
}

@end
