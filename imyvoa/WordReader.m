//
//  WordReader.m
//  imyvoa
//
//  Created by yangzexin on 12-9-28.
//
//

#import "WordReader.h"
#import <AVFoundation/AVFoundation.h>
#import "SoundDownloader.h"

@interface WordReader () <SoundDownloaderDelegate, AVAudioPlayerDelegate, WordReaderControlDelegate>

@property(nonatomic, assign)BOOL didReadFinish;
@property(nonatomic, retain)AVAudioPlayer *audioPlayer;
@property(nonatomic, retain)id<SoundDownloader> soundDownloader;
@property(nonatomic, copy)NSString *word;
@property(nonatomic, copy)WordReaderCompletion completion;
@property(nonatomic, retain)id<WordReaderControl> readerControl;

@end

@implementation WordReader

- (void)dealloc
{
    [_audioPlayer stop]; _audioPlayer.delegate = nil; [_audioPlayer release];
    [_soundDownloader cancel]; self.soundDownloader = nil;
    self.word = nil;
    self.readerControl = nil;
    [super dealloc];
}

- (void)readWord:(NSString *)word wordReaderControl:(id<WordReaderControl>)wordReaderControl completion:(WordReaderCompletion)completion
{
    self.word = word;
    self.completion = completion;
    
    self.readerControl = wordReaderControl;
    self.readerControl.delegate = self;
    [self.readerControl askForRead];
}

- (void)readWord:(NSString *)word
{
    _soundDownloader = [SoundDownloader newDownloader];
    _soundDownloader.delegate = self;
    [_soundDownloader downloadWithWord:word];
}

- (void)stop
{
    [_audioPlayer stop];
    _audioPlayer.delegate = nil;
    self.readerControl.delegate = nil;
}

- (void)providerWillRemoveFromPool
{
    [self stop];
}

- (BOOL)complete
{
    return _didReadFinish;
}

#pragma mark - WordReaderControlDelegate
- (void)wordReaderControlWantToPlay:(id)control
{
    [self readWord:self.word];
}

- (void)wordReaderControlDidFinishPlay:(id)control
{
    if(self.completion){
        self.completion();
    }
}

#pragma mark - SoundDownloaderDelegate
- (void)soundDownloader:(id)soundDownloader didSuccessWithSoundData:(NSData *)soundData
{
    self.audioPlayer = [[[AVAudioPlayer alloc] initWithData:soundData
                                                      error:nil] autorelease];
    _audioPlayer.delegate = self;
    
    [_audioPlayer play];
}

- (void)soundDownloader:(id)soundDownloader didFailWithError:(NSError *)error
{
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.readerControl askForRead];
}

@end
