//
//  HaiCiDictionary.h
//  imyvoa
//
//  Created by yzx on 12-5-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dictionary.h"
#import "HTTPRequester.h"
#import "DictionaryCache.h"

@interface OnlineDictionary : NSObject <Dictionary> {
    id<DictionaryDelegate> _delegate;
    
    NSString *_word;
    
    HTTPRequester *_httpRequester;
    
    id<DictionaryCache> _dictCache;
}

@property(nonatomic, assign)id<DictionaryDelegate> delegate;

@end

@interface OnlineDictionaryResult : NSObject <DictionaryQueryResult> {
    NSString *_html;
    NSString *_word;
}

@property(nonatomic, copy)NSString *html;
@property(nonatomic, copy)NSString *word;

@end
