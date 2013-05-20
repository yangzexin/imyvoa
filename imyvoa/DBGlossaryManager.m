//
//  DBGlossaryManager.m
//  imyvoa
//
//  Created by yzx on 12-6-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBGlossaryManager.h"
#import "SVKeyValueManager.h"
#import "SVDataBaseKeyValueManager.h"
#import "SVCommonUtils.h"
#import "SVEncryptUtils.h"

@interface DBGlossaryManager ()

@property(nonatomic, retain)id<SVKeyValueManager> glossaryLibrary;

@end

@implementation DBGlossaryManager

@synthesize glossaryLibrary = _glossaryLibrary;

- (void)dealloc
{
    [_glossaryLibrary release];
    [super dealloc];
}

- (id)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    
    NSString *fileName = [NSString stringWithFormat:@"glossary+%@", identifier];
    self.glossaryLibrary = [[[SVDataBaseKeyValueManager alloc] initWithDBName:fileName atFolder:[[SharedResource sharedInstance] cachePath]] autorelease];
    
    return self;
}

#pragma mark - GlossaryManager
- (BOOL)addWord:(NSString *)word
{
    if([self.glossaryLibrary valueForKey:word] == nil){
        [self.glossaryLibrary setValue:@"null" forKey:word];
        return YES;
    }
    return NO;
}

- (void)removeWord:(NSString *)word
{
    [self.glossaryLibrary removeValueForKey:word];
}

- (NSArray *)wordList
{
    NSMutableArray *array = [NSMutableArray array];
    NSArray *allkeys = [self.glossaryLibrary allKeys];
    for(NSInteger i = allkeys.count - 1; i >= 0; --i){
        NSString *key = [allkeys objectAtIndex:i];
        [array addObject:key];
    }
    return array;
}

@end
