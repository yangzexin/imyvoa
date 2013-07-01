//
//  ResourceCenter.m
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SharedResource.h"
#import "YXCommonUtils.h"
#import "OnlineDictionary.h"

NSString *kNewsItemDidRemoveFromCacheNotification = @"kNewsItemDidRemoveFromCacheNotification";
NSString *kNewsItemDidAddToCacheNotification = @"kNewsItemDidAddToCacheNotification";

@implementation SharedResource

@synthesize currentPlayingNewsItem = _newsItem;

+ (SharedResource *)sharedInstance
{
    static SharedResource *instance = nil;
    @synchronized(instance){
        if(instance == nil){
            instance = [[self.class alloc] init];
        }
    }
    return instance;
}

- (void)dealloc
{
    [_newsItem release];
    self.scriptApp = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    return self;
}

- (NSString *)soundTempFilePath
{
    NSString *saveFilePath = [[YXCommonUtils tmpPath] stringByAppendingPathComponent:@"tmp.mp3"];
    return saveFilePath;
}

- (NSString *)cachePath
{
    NSString *path = [[YXCommonUtils documentPath] stringByAppendingPathComponent:@"imyvoa_caches"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return path;
}

@end
