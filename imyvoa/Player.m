//
//  Player.m
//  imyvoa
//
//  Created by gewara on 12-6-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Player.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

NSString *kPlayerDidStartPlayNotification = @"kPlayerDidStartPlayNotification";
NSString *kPlayerDidPauseNotification = @"kPlayerDidPauseNotification";
NSString *kPlayerDidStopNotification = @"kPlayerDidStopNotification";
NSString *kPlayerDidChangeSoundNotification = @"kPlayerDidChangeSoundNotification";
NSString *kPlayerDidPlayFinishNotification = @"kPlayerDidPlayFinishNotification";

@interface Player () <AVAudioPlayerDelegate>

@property(nonatomic, retain)AVAudioPlayer *audioPlayer;

@end

@implementation Player

@synthesize delegate = _delegate;

@synthesize audioPlayer = _audioPlayer;
@synthesize currentSoundFilePath = _currentSoundFilePath;

+ (Player *)sharedInstance
{
    static Player *instance = nil;
    @synchronized(instance){
        if(!instance){
            instance = [[Player alloc] init];
        }
    }
    return instance;
}

- (void)dealloc
{
    [_audioPlayer release];
    [_currentSoundFilePath release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    return self;
}

- (void)playSoundAtFilePath:(NSString *)soundFilePath autoPlay:(BOOL)autoPlay
{
    if(_currentSoundFilePath != soundFilePath){
        [_currentSoundFilePath release];
        _currentSoundFilePath = nil;
    }
    _currentSoundFilePath = [soundFilePath retain];
    if([self.delegate respondsToSelector:@selector(playerDidChangeSound:)]){
        [self.delegate playerDidChangeSound:self];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPlayerDidChangeSoundNotification object:nil];
    }
    
    NSURL *fileURL = [[[NSURL alloc] initFileURLWithPath:_currentSoundFilePath] autorelease];
    self.audioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil] autorelease];
    self.audioPlayer.delegate = self;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioRouteChange, self);
    if(autoPlay){
        [self play];
    }
}

- (void)playSoundAtFilePath:(NSString *)soundFilePath
{
    [self playSoundAtFilePath:soundFilePath autoPlay:YES];
}

- (void)play
{
    [self.audioPlayer play];
    if([self.delegate respondsToSelector:@selector(playerDidStartPlay:)]){
        [self.delegate playerDidStartPlay:self];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPlayerDidStartPlayNotification object:nil];
    }
}

- (void)pause
{
    [self.audioPlayer pause];
    if([self.delegate respondsToSelector:@selector(playerDidPause:)]){
        [self.delegate playerDidPause:self];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPlayerDidPauseNotification object:nil];
    }
}

- (void)resume
{
    [self.audioPlayer play];
    if([self.delegate respondsToSelector:@selector(playerDidStartPlay:)]){
        [self.delegate playerDidStartPlay:self];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPlayerDidStartPlayNotification object:nil];
    }
}

- (void)stop
{
    [self.audioPlayer stop];
    if([self.delegate respondsToSelector:@selector(playerDidStop:)]){
        [self.delegate playerDidStop:self];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPlayerDidPauseNotification object:nil];
    }
}

- (BOOL)playing
{
    return self.audioPlayer.playing;
}

- (NSTimeInterval)duration
{
    return self.audioPlayer.duration;
}

- (NSTimeInterval)currentTime
{
    return self.audioPlayer.currentTime;
}

- (void)setCurrentTime:(NSTimeInterval)time
{
    self.audioPlayer.currentTime = time;
}

#pragma mark - AudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if([self.delegate respondsToSelector:@selector(playerDidStop:)]){
        [self.delegate playerDidStop:self];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPlayerDidStopNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kPlayerDidPlayFinishNotification object:nil];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags
{
}

#pragma mark - listeners
void audioRouteChange(
                      void *                  inClientData,
                      AudioSessionPropertyID	inID,
                      UInt32                  inDataSize,
                      const void *            inData)
{
    CFDictionaryRef    routeChangeDictionary = inData;  
    CFNumberRef routeChangeReasonRef = CFDictionaryGetValue(routeChangeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
    SInt32 routeChangeReason;
    CFNumberGetValue(routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason); 
    if(routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable){
        [(id)inClientData pause];
    }else if(routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable){
    }
}

@end
