//
//  SoundListCache.h
//  imyvoa
//
//  Created by yangzexin on 12-9-28.
//
//

#import <Foundation/Foundation.h>
#import "SVProviderPool.h"

typedef void(^SoundListCacheCompletion) (NSArray *wordList, NSArray *failureList);
typedef void(^SoundListCacheStep) (NSString *word);

@protocol WordSoundListCache <ProviderPoolable>

- (void)cacheWordList:(NSArray *)wordList step:(SoundListCacheStep)step completion:(SoundListCacheCompletion)completion;

@end

@interface WordSoundListCache : NSObject <WordSoundListCache>

@end
