//
//  HaiCiDictionary.m
//  imyvoa
//
//  Created by yzx on 12-5-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OnlineDictionary.h"
#import "SVEncryptUtils.h"
#import "DBDictionaryCache.h"
#import "DictonaryWord.h"
#import "SVApp.h"
#import "SVAppManager.h"
#import "SVApplicationScriptBundle.h"
#import "AppDelegate.h"

@interface OnlineDictionary () <HTTPRequesterDelegate>

@property(nonatomic, copy)NSString *word;

@property(nonatomic, retain)HTTPRequester *httpRequester;

@property(nonatomic, retain)id<DictionaryCache> dictCache;

- (void)notifySucceed:(NSString *)contentHTML;

@end

@implementation OnlineDictionary

@synthesize delegate = _delegate;

@synthesize word = _word;

@synthesize httpRequester = _httpRequester;

@synthesize dictCache = _dictCache;

- (void)dealloc
{
    [_httpRequester cancel]; [_httpRequester release];
    [_word release];
    [_dictCache release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.dictCache = [[[DBDictionaryCache alloc] init] autorelease];
    
    return self;
}

- (NSString *)name
{
    return [SVAppManager runApp:[AppDelegate sharedAppDelegate].scriptApp params:[NSArray arrayWithObject:@"dictionary_name"]];
}

- (void)query:(NSString *)str delegate:(id<DictionaryDelegate>)delegate
{
    self.delegate = delegate;
    
    self.word = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.word = [self.word stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    DictonaryWord *dictWord = [self.dictCache query:self.word];
    if(dictWord != nil){
//        NSLog(@"from cache:%@", dictWord.word);
        [self notifySucceed:dictWord.definition];
    }else{
        NSString *urlString = [SVAppManager runApp:[AppDelegate sharedAppDelegate].scriptApp
                                            params:[NSArray arrayWithObjects:@"dictionary_url", str, nil]];
        self.httpRequester = [HTTPRequester newHTTPRequester];
        self.httpRequester.urlString = urlString;
        self.httpRequester.delegate = self;
        [self.httpRequester request];
    }
}

- (id<DictionaryQueryResult>)queryFromCache:(NSString *)str
{
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    DictonaryWord *dictWord = [self.dictCache query:str];
    if(dictWord){
        OnlineDictionaryResult *dictResult = [[[OnlineDictionaryResult alloc] init] autorelease];
        dictResult.html = dictWord.definition;
        dictResult.word = self.word;
        
        return dictResult;
    }
    
    return nil;
}

- (void)providerWillRemoveFromPool
{
    self.delegate = nil;
}

- (void)notifySucceed:(NSString *)definition
{
    OnlineDictionaryResult *dictResult = [[[OnlineDictionaryResult alloc] init] autorelease];
    dictResult.html = definition;
    dictResult.word = self.word;
    
    if([self.delegate respondsToSelector:@selector(dictionary:didFinishWithResult:)]){
        [self.delegate dictionary:self didFinishWithResult:dictResult];
    }
}

- (NSString *)analyzeContent:(NSString *)content
{
    NSString *result = [SVAppManager runApp:[AppDelegate sharedAppDelegate].scriptApp
                                     params:[NSArray arrayWithObjects:@"analyse_dictionary_content", content, nil]];
    return result;
}

#pragma mark - HTTPRequesterDelegate
- (void)HTTPRequester:(HTTPRequester *)requester didFinishedWithResult:(id)result
{
    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    startTime = [NSDate timeIntervalSinceReferenceDate];
    result = [self analyzeContent:result];
    
    DictonaryWord *cacheWord = [[[DictonaryWord alloc] init] autorelease];
    cacheWord.word = self.word;
    cacheWord.definition = result;
    [self.dictCache addWord:cacheWord];
    
    [self notifySucceed:result];
}

- (void)HTTPRequester:(HTTPRequester *)requester didErrored:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(dictionary:didFailWithError:)]){
        [self.delegate dictionary:self didFailWithError:error];
    }
}

@end

@implementation OnlineDictionaryResult

@synthesize html = _html;
@synthesize word = _word;

- (void)dealloc
{
    [_html release];
    [_word release];
    [super dealloc];
}

- (NSString *)contentHTML
{
    return _html;
}

- (NSString *)word
{
    return _word;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@", self.word, self.html];
}

@end
