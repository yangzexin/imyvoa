//
//  DictionaryCache.h
//  imyvoa
//
//  Created by yzx on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DictonaryWord;

@protocol DictionaryCache <NSObject>

- (void)addWord:(DictonaryWord *)word;
- (DictonaryWord *)query:(NSString *)word;
- (void)clearAllCache;

@end
