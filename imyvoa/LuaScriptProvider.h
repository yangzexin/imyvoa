//
//  LuaScriptProvider.h
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentProvider.h"

@protocol LuaScriptProviderDelegate <NSObject>

@optional
- (void)luaScriptProvider:(id)provider didRecieveResult:(NSString *)result;
- (void)luaScriptProvider:(id)provider didFailedWithError:(NSError *)error;

@end

@protocol LuaScriptProvider <ContentProvider>

- (void)getScript:(id<LuaScriptProviderDelegate>)delegate;

@end
