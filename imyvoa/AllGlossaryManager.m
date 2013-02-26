//
//  AllGlossaryManager.m
//  imyvoa
//
//  Created by yangzexin on 10/10/12.
//
//

#import "AllGlossaryManager.h"
#import "DBGlossaryManager.h"

@interface AllGlossaryManager ()

@property(nonatomic, retain)id<GlossaryManager> glossaryManager;

@end

@implementation AllGlossaryManager

@synthesize glossaryManager;

+ (id)sharedManager
{
    static id instance = nil;
    
    @synchronized(self.class){
        if(instance == nil){
            instance = [[self alloc] init];
        }
    }
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    self.glossaryManager = [[[DBGlossaryManager alloc] initWithIdentifier:@"all_glossary"] autorelease];
    
    return self;
}

- (BOOL)addWord:(NSString *)word
{
    return [self.glossaryManager addWord:word];
}

- (void)removeWord:(NSString *)word
{
    [self.glossaryManager removeWord:word];
}

- (NSArray *)wordList
{
    return self.glossaryManager.wordList;
}

@end
