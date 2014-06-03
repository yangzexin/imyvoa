//
//  AppDelegate.h
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dictionary.h"

OBJC_EXPORT NSString *kNewsItemDidRemoveFromCacheNotification;
OBJC_EXPORT NSString *kNewsItemDidAddToCacheNotification;

@class DictionaryViewController;
@class NewsItem;
@class SVApp;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UINavigationController *_newsListNC;
    UINavigationController *_localNewsListNC;
}

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, retain)NewsItem *currentPlayingNewsItem; // 当前正在播放的新闻
@property(nonatomic, retain)SVApp *scriptApp;

+ (instancetype)sharedAppDelegate;

- (NSString *)soundTempFilePath; // 下载声音文件临时目录
- (NSString *)cachePath;

@end
