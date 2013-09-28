//
//  GHHaikuInstance.h
//  GayHaikuTabbed
//
//  Created by Joel Derfner on 3/17/13.
//  Copyright (c) 2013 Joel Derfner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHHaikuInstance : NSObject

@property (nonatomic) BOOL justComposed;
@property (nonatomic) BOOL isUserHaiku;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic) BOOL userIsEditing;
@property (nonatomic, strong) NSString *text;

@end
