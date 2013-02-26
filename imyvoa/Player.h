//
//  Player.h
//  imyvoa
//
//  Created by gewara on 12-6-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVAudioPlayer;
@class Player;

OBJC_EXPORT NSString *kPlayerDidStartPlayNotification;
OBJC_EXPORT NSString *kPlayerDidPauseNotification;
OBJC_EXPORT NSString *kPlayerDidStopNotification;
OBJC_EXPORT NSString *kPlayerDidChangeSoundNotification;
OBJC_EXPORT NSString *kPlayerDidPlayFinishNotification;

@protocol PlayerDelegate <NSObject>

@optional
- (void)playerDidStartPlay:(Player *)player;
- (void)playerDidPause:(Player *)player;
- (void)playerDidStop:(Player *)player;
- (void)playerDidChangeSound:(Player *)player;

@end

@interface Player : NSObject {
@private
    id<PlayerDelegate> _delegate;
    AVAudioPlayer *_audioPlayer;
    
    NSString *_currentSoundFilePath;
}

@property(nonatomic, assign)id<PlayerDelegate> delegate;

@property(nonatomic, readonly)NSString *currentSoundFilePath;

+ (Player *)sharedInstance;

- (void)playSoundAtFilePath:(NSString *)soundFilePath;
- (void)playSoundAtFilePath:(NSString *)soundFilePath autoPlay:(BOOL)autoPlay;
- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;
- (BOOL)playing;
- (NSTimeInterval)duration;
- (NSTimeInterval)currentTime;
- (void)setCurrentTime:(NSTimeInterval)time;

@end
