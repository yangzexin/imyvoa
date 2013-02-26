//
//  ResourceCenter.h
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dictionary.h"

OBJC_EXPORT NSString *kNewsItemDidRemoveFromCacheNotification;
OBJC_EXPORT NSString *kNewsItemDidAddToCacheNotification;

@class NewsItem;

@interface SharedResource : NSObject {
    NewsItem *_newsItem;
}

@property(nonatomic, retain)NewsItem *currentPlayingNewsItem; // 当前正在播放的新闻

+ (SharedResource *)sharedInstance;

- (NSString *)luaScriptVersionCode; // lua 脚本版本号

- (NSString *)soundTempFilePath; // 下载声音文件临时目录
- (NSString *)cachePath;

@end
