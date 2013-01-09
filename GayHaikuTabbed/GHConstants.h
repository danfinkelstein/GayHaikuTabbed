//
//  GHConstants.h
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 1/8/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import <Foundation/Foundation.h>

extern float const screenWidth;
extern float const tabBarHeight;
extern float const toolbarHeight;
extern float const keyboardHeight;
extern float const buttonSideLength;

@interface GHConstants : NSObject

-(UITextView *)createSwipeToAdd:(NSString *)word;
-(UITextView *)createParagraph:(UITextView *)tv;

@end
