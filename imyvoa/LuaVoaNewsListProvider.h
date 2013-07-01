//
//  LuaVoaNewsListProvider.h
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoaNewsListProvider.h"
#import "YXKeyValueManager.h"
#import "LuaScriptProvider.h"

@class HTTPRequester;

@interface LuaVoaNewsListProvider : NSObject <VoaNewsListProvider> {
    id<VoaNewsListProviderDelegate> _delegate;
    HTTPRequester *_httpRequester;
    
    id<YXKeyValueManager> _cache;
    
    id<LuaScriptProvider> _luaScriptProvider;
}

@property(nonatomic, assign)id<VoaNewsListProviderDelegate> delegate;

@end
