//
//  DictonaryWord.m
//  imyvoa
//
//  Created by yzx on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DictonaryWord.h"

@implementation DictonaryWord

@synthesize word;
@synthesize definition;

- (void)dealloc
{
    [word release];
    [definition release];
    [super dealloc];
}

@end
