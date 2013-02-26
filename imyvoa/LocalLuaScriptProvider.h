//
//  LocalLuaScriptProvider.h
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LuaScriptProvider.h"
#import "TaskQueue.h"

@interface LocalLuaScriptProvider : NSObject <LuaScriptProvider> {
    id<LuaScriptProviderDelegate> _delegate;
}

@property(nonatomic, assign)id<LuaScriptProviderDelegate> delegate;

@end
