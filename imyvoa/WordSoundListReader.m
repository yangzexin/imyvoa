//
//  SoundListReader.m
//  imyvoa
//
//  Created by yangzexin on 12-9-28.
//
//

#import "WordSoundListReader.h"
#import "WordReader.h"
#import "WordReaderControl.h"

@interface WordSoundListReader ()

@property(nonatomic, assign)NSInteger currentPlayIndex;
@property(nonatomic, retain)NSArray *wordList;
@property(nonatomic, retain)id<WordReader> reader;
@property(nonatomic, copy)SoundListReaderCompletion completion;
@property(nonatomic, assign)BOOL playing;

@end

@implementation WordSoundListReader

- (void)dealloc
{
    self.wordList = nil;
    [super dealloc];
}

- (void)playWithWordList:(NSArray *)wordList completion:(SoundListReaderCompletion)completion
{
    self.currentPlayIndex = 0;
    self.completion = completion;
    self.wordList = wordList;
    self.reader = [[[WordReader alloc] init] autorelease];
    self.playing = YES;
    [self readNext];
}

- (void)readNext
{
    NSString *word = [self nextWord];
    if(!word){
        self.playing = NO;
        if(self.completion){
            self.completion();
        }
    }else{
        __block typeof(self) bself = self;
        [self.reader readWord:word wordReaderControl:[[[RepeatTwiceWordReaderControl alloc] initWithRepeatCount:2] autorelease] completion:^{
            [bself readNext];
        }];
    }
}

- (NSString *)nextWord
{
    if(_currentPlayIndex < self.wordList.count){
        return [self.wordList objectAtIndex:_currentPlayIndex++];
    }
    return nil;
}

- (void)stop
{
    [self.reader stop];
    self.playing = NO;
}

@end
