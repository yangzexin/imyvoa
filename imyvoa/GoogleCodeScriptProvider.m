//
//  GoogleCodeScriptProvider.m
//  imyvoa
//
//  Created by yzx on 12-6-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GoogleCodeScriptProvider.h"

@implementation GoogleCodeScriptProvider

@synthesize delegate = _delegate;

- (void)dealloc
{
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    
    
    return self;
}

- (void)getScript:(id<LuaScriptProviderDelegate>)delegate
{

}

- (void)providerWillRemoveFromPool
{
    
}

@end
