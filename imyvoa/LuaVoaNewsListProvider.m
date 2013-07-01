//
//  LuaVoaNewsListProvider.m
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LuaVoaNewsListProvider.h"
#import "HTTPRequester.h"
#import "NewsItem.h"
#import "YXDatabaseKeyValueManager.h"
#import "LocalLuaScriptProvider.h"
#import "YXAppManager.h"

@interface LuaVoaNewsListProvider () <HTTPRequesterDelegate, HTTPRequesterDataSource, LuaScriptProviderDelegate>

@property(nonatomic, retain)HTTPRequester *httpRequester;

@property(nonatomic, retain)id<YXKeyValueManager> cache;

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
    
    self.cache = [[[YXDatabaseKeyValueManager alloc] initWithDBName:@"news_list" atFolder:[[SharedResource sharedInstance] cachePath]] autorelease];
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
    [self requestNewsList];
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

#pragma mark - HTTPRequesterDataSource
- (NSString *)urlStringForHTTPRequester:(HTTPRequester *)requester
{
    NSString *urlString = [YXAppManager runApp:[SharedResource sharedInstance].scriptApp
                                        params:[NSArray arrayWithObjects:@"news_list_url", nil]];
    
    return urlString;
}

#pragma mark - HTTPRequesterDelegate
- (void)HTTPRequester:(HTTPRequester *)requester didFinishedWithResult:(id)result
{
    if([result length] != 0){
        [self saveCache:result];
    }
    
    NSString *formattedResult = [YXAppManager runApp:[SharedResource sharedInstance].scriptApp
                                              params:[NSArray arrayWithObjects:@"analyse_news_list", result, nil]];
    NSMutableArray *newsList = nil;
    if(formattedResult){
        newsList = [NSMutableArray array];
        NSArray *itemList = [formattedResult componentsSeparatedByString:
                             [YXAppManager runApp:[SharedResource sharedInstance].scriptApp
                                           params:[NSArray arrayWithObject:@"news_item_separator"]]];
        NSString *linkSeparator = [YXAppManager runApp:[SharedResource sharedInstance].scriptApp
                                                params:[NSArray arrayWithObject:@"news_item_link_separator"]];
        for(NSString *item in itemList){
            NSArray *tmp = [item componentsSeparatedByString:linkSeparator];
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
