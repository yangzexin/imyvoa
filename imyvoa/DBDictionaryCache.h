//
//  DBDictionaryCache.h
//  imyvoa
//
//  Created by yzx on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DictionaryCache.h"
#import "YXKeyValueManager.h"

@interface DBDictionaryCache : NSObject <DictionaryCache> {
    id<YXKeyValueManager> _keyValueCache;
}

+ (DBDictionaryCache *)sharedInstance;

@end
