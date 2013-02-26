//
//  SoundListCache.m
//  imyvoa
//
//  Created by yangzexin on 12-9-28.
//
//

#import "WordSoundListCache.h"
#import "SoundDownloader.h"

@interface WordSoundListCache () <SoundDownloaderDelegate>

@property(nonatomic, copy)SoundListCacheStep step;
@property(nonatomic, copy)SoundListCacheCompletion completion;
@property(nonatomic, retain)NSArray *wordList;
@property(nonatomic, retain)NSMutableArray *failureList;
@property(nonatomic, assign)NSInteger currentWordIndex;
@property(nonatomic, retain)id<SoundDownloader> soundDownloader;

@end

@implementation WordSoundListCache

- (void)dealloc
{
    self.step = nil;
    self.completion = nil;
    self.wordList = nil;
    self.failureList = nil;
    [self.soundDownloader cancel]; self.soundDownloader = nil;
    [super dealloc];
}

- (void)cacheWordList:(NSArray *)wordList step:(SoundListCacheStep)step completion:(SoundListCacheCompletion)completion
{
    self.wordList = wordList;
    self.failureList = [NSMutableArray array];
    self.step = step;
    self.completion = completion;
    self.currentWordIndex = 0;
    
    self.soundDownloader = [SoundDownloader newDownloader];
    [self.soundDownloader setDelegate:self];
    [self downloadNextWord];
}

- (NSString *)nextWord
{
    if(self.currentWordIndex < self.wordList.count){
        return [self.wordList objectAtIndex:self.currentWordIndex++];
    }
    return nil;
}

- (NSString *)currentWord
{
    if(self.currentWordIndex > 1){
        return [self.wordList objectAtIndex:self.currentWordIndex - 1];
    }
    return nil;
}

- (void)downloadNextWord
{
    NSString *word = [self nextWord];
    if(word){
        if(self.step){
            self.step(word);
        }
        [self.soundDownloader downloadWithWord:word];
    }else{
        // no more
        self.currentWordIndex = -1;
        if(self.completion){
            self.completion(self.wordList, self.failureList);
        }
    }
}

- (void)providerWillRemoveFromPool
{
    self.step = nil;
    self.completion = nil;
    [self.soundDownloader cancel];
}

- (BOOL)providerShouldBeRemoveFromPool
{
    return self.currentWordIndex == -1;
}

#pragma mark - SoundDownloaderDelegate
- (void)soundDownloader:(id)soundDownloader didSuccessWithSoundData:(NSData *)soundData
{
    [self downloadNextWord];
}

- (void)soundDownloader:(id)soundDownloader didFailWithError:(NSError *)error
{
    [self.failureList addObject:[self currentWord]];
    [self downloadNextWord];
}

@end
