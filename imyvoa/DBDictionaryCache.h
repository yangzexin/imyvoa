//
//  DBDictionaryCache.h
//  imyvoa
//
//  Created by yzx on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DictionaryCache.h"
#import "SVKeyValueManager.h"

@interface DBDictionaryCache : NSObject <DictionaryCache> {
    id<SVKeyValueManager> _keyValueCache;
}

+ (DBDictionaryCache *)sharedInstance;

@end
