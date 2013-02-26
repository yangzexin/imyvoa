//
//  LuaVoaNewsListProvider.m
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LuaVoaNewsListProvider.h"
#import "LuaHelper.h"
#import "HTTPRequester.h"
#import "NewsItem.h"
#import "DataBaseKeyValueManager.h"
#import "LocalLuaScriptProvider.h"

@interface LuaVoaNewsListProvider () <HTTPRequesterDelegate, HTTPRequesterDataSource, LuaScriptProviderDelegate>

@property(nonatomic, retain)HTTPRequester *httpRequester;

@property(nonatomic, retain)id<KeyValueManager> cache;

@property(nonatomic, retain)id<LuaScriptProvider> luaScriptProvider;

- (void)saveCache:(NSString *)cache;
- (NSString *)readCache;

@end

@implementation LuaVoaNewsListProvider

@synthesize delegate = _delegate;
@synthesize httpRequester = _httpRequester;

@synthesize cache = _cache;

@synthesize luaScriptProvider = _luaScriptProvider;

- (void)dealloc
{
    [_httpRequester cancel]; [_httpRequester release];
    
    [_cache release];
    
    [_luaScriptProvider providerWillRemoveFromPool]; [_luaScriptProvider release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.cache = [[[DataBaseKeyValueManager alloc] initWithDBName:@"news_list" atFolder:[[SharedResource sharedInstance] cachePath]] autorelease];
    self.luaScriptProvider = [[[LocalLuaScriptProvider alloc] init] autorelease];
    
    return self;
}

- (void)requestNewsList
{
    self.httpRequester = [HTTPRequester newHTTPRequester];
    self.httpRequester.delegate = self;
    self.httpRequester.dataSource = self;
    [self.httpRequester request];
}

- (void)requestNewsListWithDelegate:(id<VoaNewsListProviderDelegate>)delegate
{
    self.delegate = delegate;
    
    if([LuaHelper sharedInstance].script.length == 0){
        // 脚本未加载
        [self.luaScriptProvider getScript:self];
    }else{
        // 脚本已经加载，请求列表
        [self requestNewsList];
    }
}

- (void)providerWillRemoveFromPool
{
    self.delegate = nil;
}

- (void)saveCache:(NSString *)cache
{
    [self.cache setValue:cache forKey:@"news_list"];
}

- (NSString *)readCache
{
    return [self.cache valueForKey:@"news_list"];
}

#pragma mark - LuaScriptProviderDelegate
- (void)luaScriptProvider:(id)provider didRecieveResult:(NSString *)result
{
    NSLog(@"lua script hava loaded succeed");
    [LuaHelper sharedInstance].script = result;
    // 脚本加载完毕，请求新闻
    [self requestNewsList];
}

- (void)luaScriptProvider:(id)provider didFailedWithError:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(voaNewsListProvider:didFailedWithError:)]){
        [self.delegate voaNewsListProvider:self didFailedWithError:error];
    }
}

#pragma mark - HTTPRequesterDataSource
- (NSString *)urlStringForHTTPRequester:(HTTPRequester *)requester
{
    NSString *urlString = [[LuaHelper sharedInstance] invokeProperty:@"specialVOAURLString"];
    
    return urlString;
}

#pragma mark - HTTPRequesterDelegate
- (void)HTTPRequester:(HTTPRequester *)requester didFinishedWithResult:(id)result
{
    if([result length] != 0){
        [self saveCache:result];
    }
    
    NSString *formattedResult = [[LuaHelper sharedInstance] invokeMethodWithName:@"analyseNewsList" 
                                                                      paramValue:result];
    NSMutableArray *newsList = nil;
    if(formattedResult){
        newsList = [NSMutableArray array];
        NSArray *itemList = [formattedResult componentsSeparatedByString:
                             [[LuaHelper sharedInstance] invokeProperty:@"itemSeparator"]];
        for(NSString *item in itemList){
            NSArray *tmp = [item componentsSeparatedByString:
                            [[LuaHelper sharedInstance] invokeProperty:@"linkSeparator"]];
            if(tmp.count == 2){
                NewsItem *newsItem = [[NewsItem alloc] init];
                newsItem.title = [tmp objectAtIndex:1];
                newsItem.contentLink = [tmp objectAtIndex:0];
                [newsList addObject:newsItem];
                [newsItem release];
            }
        }
    }
    if([self.delegate respondsToSelector:@selector(voaNewsListProvider:didRecieveList:)]){
        [self.delegate voaNewsListProvider:self didRecieveList:newsList];
    }
}

- (void)HTTPRequester:(HTTPRequester *)requester didErrored:(NSError *)error
{
    NSString *cache = [self readCache];
    NSLog(@"news list from cache");
    if(cache.length != 0){
        [self HTTPRequester:requester didFinishedWithResult:cache];
    }else{
        if([self.delegate respondsToSelector:@selector(voaNewsListProvider:didFailedWithError:)]){
            [self.delegate voaNewsListProvider:self didFailedWithError:error];
        }
    }
}
@end
