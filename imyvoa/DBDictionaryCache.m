//
//  DBDictionaryCache.m
//  imyvoa
//
//  Created by yzx on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBDictionaryCache.h"
#import "SVCommonUtils.h"
#import "SVEncryptUtils.h"
#import "DictonaryWord.h"
#import "SVDataBaseKeyValueManager.h"

@interface DBDictionaryCache ()

@property(nonatomic, retain)id<SVKeyValueManager> keyValueCache;

@end

@implementation DBDictionaryCache

@synthesize keyValueCache = _keyValueCache;

+ (DBDictionaryCache *)sharedInstance
{
    static DBDictionaryCache *instance = nil;
    @synchronized(instance){
        if(instance == nil){
            instance = [[DBDictionaryCache alloc] init];
        }
    }
    return instance;
}

- (void)dealloc
{
    [_keyValueCache release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.keyValueCache = [[[SVDataBaseKeyValueManager alloc] initWithDBName:@"dictionary cache" atFolder:[[SharedResource sharedInstance] cachePath]] autorelease];
    
    return self;
}

#pragma mark - DictionaryCache
- (void)addWord:(DictonaryWord *)word
{
//    NSLog(@"%@, %@", word.word, word.definition);
    [self.keyValueCache setValue:word.definition forKey:word.word];
}

- (DictonaryWord *)query:(NSString *)word
{   
    DictonaryWord *dictWord = nil;
    
    NSString *definition = [self.keyValueCache valueForKey:word];
    if(definition){
        dictWord = [[[DictonaryWord alloc] init] autorelease];
        dictWord.word = word;
        dictWord.definition = definition;
    }
    
    return dictWord;
}

- (void)clearAllCache
{
    [self.keyValueCache clear];
}

@end
