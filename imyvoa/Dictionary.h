//
//  Dictionary.h
//  imyvoa
//
//  Created by yzx on 12-5-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentProvider.h"

@protocol DictionaryQueryResult <NSObject>

- (NSString *)contentHTML;
- (NSString *)word;

@end

@protocol DictionaryDelegate <NSObject>

@optional
- (void)dictionary:(id)dictionary didFinishWithResult:(id<DictionaryQueryResult>)result;
- (void)dictionary:(id)dictionary didFailWithError:(NSError *)error;

@end

@protocol Dictionary <ContentProvider>

- (NSString *)name;
- (void)query:(NSString *)str delegate:(id<DictionaryDelegate>)delegate;
- (id<DictionaryQueryResult>)queryFromCache:(NSString *)str;

@end
