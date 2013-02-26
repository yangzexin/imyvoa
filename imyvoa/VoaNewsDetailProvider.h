//
//  VoaNewsContentProvider.h
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentProvider.h"
#import "NewsItem.h"

@protocol VoaNewsDetailProviderDelegate <NSObject>

@optional
- (void)voaNewsContentProvider:(id)provider didRecieveResult:(NewsItem *)result;
- (void)voaNewsContentProvider:(id)provider didFailedWithError:(NSError *)error;

@end

@protocol VoaNewsDetailProvider <ContentProvider>

- (void)requestWithNewsItem:(NewsItem *)item delegate:(id<VoaNewsDetailProviderDelegate>)delegate ignoreCache:(BOOL)ignoreCache;
- (NewsItem *)newsItemFromLocalCache:(NewsItem *)item;
- (NSArray *)localCacheNewsItemList;
- (void)removeCacheWithNewsItem:(NewsItem *)item;
- (void)clearCaches;

@end
