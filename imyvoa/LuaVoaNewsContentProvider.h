//
//  LuaVoaNewsContentProvider.h
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoaNewsDetailProvider.h"
#import "KeyValueManager.h"

@class HTTPRequester;

@interface LuaVoaNewsContentProvider : NSObject <VoaNewsDetailProvider> {
    id<VoaNewsDetailProviderDelegate> _delegate;
    
    NewsItem *_newsItem;
    HTTPRequester *_httpRequester;
    
    id<KeyValueManager> _keyValueCache;
}

@property(nonatomic, assign)id<VoaNewsDetailProviderDelegate> delegate;

@end
