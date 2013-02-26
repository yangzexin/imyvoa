//
//  ForTestScriptCheckUpdateProvider.m
//  imyvoa
//
//  Created by yzx on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ForTestScriptCheckUpdateProvider.h"

@implementation ForTestScriptCheckUpdateProvider

@synthesize delegate = _delegate;

- (void)dealloc
{
    [super dealloc];
}

- (void)checkUpdateWithLocalVersionCode:(NSString *)versionCode
{
    [NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];
}

- (void)notifyCheckUpdateDidSucceed
{
    if([self.delegate respondsToSelector:@selector(scriptCheckUpdateProvider:didSucceedWithResult:)]){
        [self.delegate scriptCheckUpdateProvider:self didSucceedWithResult:NO];
    }
}

- (void)run
{
    @autoreleasepool {
        [NSThread sleepForTimeInterval:1.0];
        [self performSelectorOnMainThread:@selector(notifyCheckUpdateDidSucceed) 
                               withObject:nil 
                            waitUntilDone:YES];
    }
}

- (void)providerWillRemoveFromPool
{
    self.delegate = nil;
}

- (void)execute:(id)userData
{
    [self checkUpdateWithLocalVersionCode:userData];
}

- (NSString *)taskDescription
{
    return @"ScriptCheckUpdateProvider";
}

@end
