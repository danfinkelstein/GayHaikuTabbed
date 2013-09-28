//
//  GHHaikuInstance.m
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 3/17/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import "GHHaikuInstance.h"

@implementation GHHaikuInstance

@synthesize justComposed, isFavorite, isUserHaiku, userIsEditing, text;

-(NSString *)description {
    return self.text;
}

@end
