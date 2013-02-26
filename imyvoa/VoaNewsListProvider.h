//
//  VoaNewsListProvider.h
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentProvider.h"

@protocol VoaNewsListProviderDelegate <NSObject>

@optional
- (void)voaNewsListProvider:(id)provider didRecieveList:(NSArray *)list;
- (void)voaNewsListProvider:(id)provider didFailedWithError:(NSError *)error;

@end

@protocol VoaNewsListProvider <ContentProvider>

- (void)requestNewsListWithDelegate:(id<VoaNewsListProviderDelegate>)delegate;

@end