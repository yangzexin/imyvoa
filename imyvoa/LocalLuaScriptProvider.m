//
//  LocalLuaScriptProvider.m
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LocalLuaScriptProvider.h"
#import "SVCommonUtils.h"

@implementation LocalLuaScriptProvider

@synthesize delegate = _delegate;

- (void)dealloc
{
    [super dealloc];
}

- (void)getScript:(id<LuaScriptProviderDelegate>)delegate
{
    self.delegate = delegate;
    
    //NSString *scriptFilePath = [[Utils documentPath] stringByAppendingPathComponent:@"common.lua"];
    NSString *scriptFilePath = [[NSBundle mainBundle] pathForResource:@"common" ofType:@"lua"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:scriptFilePath];
    if(fileExists){
        NSString *script = [NSString stringWithContentsOfFile:scriptFilePath 
                                                     encoding:NSUTF8StringEncoding 
                                                        error:nil];
        if([self.delegate respondsToSelector:@selector(luaScriptProvider:didRecieveResult:)]){
            [self.delegate luaScriptProvider:self didRecieveResult:script];
        }
    }else{
        if([self.delegate respondsToSelector:@selector(luaScriptProvider:didFailedWithError:)]){
            [self.delegate luaScriptProvider:self didFailedWithError:nil];
        }
    }
}

- (void)providerWillRemoveFromPool
{
    self.delegate = nil;
}

@end
