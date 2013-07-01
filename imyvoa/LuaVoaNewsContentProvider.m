//
//  LuaVoaNewsContentProvider.m
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LuaVoaNewsContentProvider.h"
#import "HTTPRequester.h"
#import "YXDatabaseKeyValueManager.h"
#import "YXEncryptUtils.h"
#import "YXAppManager.h"

@interface LuaVoaNewsContentProvider () <HTTPRequesterDelegate>

@property(nonatomic, retain)NewsItem *newsItem;
@property(nonatomic, retain)HTTPRequester *httpRequester;

@property(nonatomic, retain)id<YXKeyValueManager> keyValueCache;

@end

@implementation LuaVoaNewsContentProvider

@synthesize delegate = _delegate;

@synthesize newsItem = _newsItem;
@synthesize httpRequester = _httpRequester;

@synthesize keyValueCache = _keyValueCache;

- (void)dealloc
{
    [_newsItem release];
    [_httpRequester cancel]; [_httpRequester release];
    
    [_keyValueCache release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.keyValueCache = [[[YXDatabaseKeyValueManager alloc] initWithDBName:@"voa_news_content_cache" atFolder:[[SharedResource sharedInstance] cachePath]] autorelease];
    
    return self;
}

- (void)requestWithNewsItem:(NewsItem *)item delegate:(id<VoaNewsDetailProviderDelegate>)delegate ignoreCache:(BOOL)ignoreCache
{
    self.delegate = delegate;
    
    self.newsItem = item;
    
    NSString *cacheDataHexString = [self.keyValueCache valueForKey:[YXEncryptUtils hexStringByEncodingString:item.title]];
    if(!ignoreCache && cacheDataHexString){
        // from cache
        NSData *cacheData = [YXEncryptUtils dataByDecodingHexString:cacheDataHexString];
        NewsItem *item = [NSKeyedUnarchiver unarchiveObjectWithData:cacheData];
        NSLog(@"from cache:%@", item.title);
        if([self.delegate respondsToSelector:@selector(voaNewsContentProvider:didRecieveResult:)]){
            [self.delegate voaNewsContentProvider:self didRecieveResult:item];
        }
    }else{
        self.httpRequester = [HTTPRequester newHTTPRequester];
        self.httpRequester.urlString = item.contentLink;
        self.httpRequester.delegate = self;
        [self.httpRequester request];
    }
}

- (NewsItem *)newsItemFromLocalCache:(NewsItem *)item
{
    NSString *cacheDataHexString = [self.keyValueCache valueForKey:[YXEncryptUtils hexStringByEncodingString:item.title]];
    if(cacheDataHexString){
        NSData *cacheData = [YXEncryptUtils dataByDecodingHexString:cacheDataHexString];
        NewsItem *targetItem = [NSKeyedUnarchiver unarchiveObjectWithData:cacheData];
        return targetItem;
    }
    return nil;
}

- (NSArray *)localCacheNewsItemList
{
    NSArray *keyList = [self.keyValueCache allKeys];
    NSMutableArray *newsItemList = nil;
    if(keyList.count != 0){
        newsItemList = [NSMutableArray array];
        for(NSString *key in keyList){
            NSData *cacheData = [YXEncryptUtils dataByDecodingHexString:[self.keyValueCache valueForKey:key]];
            NewsItem *newsItem = [NSKeyedUnarchiver unarchiveObjectWithData:cacheData];
            [newsItemList addObject:newsItem];
        }
    }
    
    return newsItemList;
}

- (void)removeCacheWithNewsItem:(NewsItem *)item
{
    [self.keyValueCache removeValueForKey:[YXEncryptUtils hexStringByEncodingString:item.title]];
}

- (void)clearCaches
{
    [self.keyValueCache clear];
}

- (void)providerWillRemoveFromPool
{
    self.delegate = nil;
}

#pragma mark - HTTPRequesterDelegate
- (void)HTTPRequester:(HTTPRequester *)requester didFinishedWithResult:(id)result
{
    NewsItem *item = [self.newsItem copy];
    
    item.content = [YXAppManager runApp:[SharedResource sharedInstance].scriptApp
                                 params:[NSArray arrayWithObjects:@"analyse_news_content", result, nil]];
    const char *css = {"font-size:18px;font-weight:bold;padding-bottom:20px;"};
    NSString *title = [NSString stringWithFormat:@"<div style=\"%@\">%@</div>", 
                       [NSString stringWithUTF8String:css], item.title];
    item.content = [item.content stringByReplacingOccurrencesOfString:@"$title" 
                                                           withString:title];
    item.soundLink = [YXAppManager runApp:[SharedResource sharedInstance].scriptApp
                                   params:[NSArray arrayWithObjects:@"analyse_news_sound_url", result, nil]];
    
    // add to cache
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:item];
    NSString *encodedString = [YXEncryptUtils hexStringByEncodingData:archivedData];
    NSString *itemName = [YXEncryptUtils hexStringByEncodingString:item.title];
    [self.keyValueCache setValue:encodedString forKey:itemName];
    
    if([self.delegate respondsToSelector:@selector(voaNewsContentProvider:didRecieveResult:)]){
        [self.delegate voaNewsContentProvider:self didRecieveResult:item];
    }
}
- (void)HTTPRequester:(HTTPRequester *)requester didErrored:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(voaNewsContentProvider:didFailedWithError:)]){
        [self.delegate voaNewsContentProvider:self didFailedWithError:error];
    }
}

@end
