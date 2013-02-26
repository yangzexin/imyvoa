//
//  PlaySoundView.m
//  imyvoa
//
//  Created by yangzexin on 9/25/12.
//
//

#import "PlaySoundView.h"
#import "SoundDownloader.h"
#import <AVFoundation/AVFoundation.h>

@interface PlaySoundView () <SoundDownloaderDelegate, AVAudioPlayerDelegate>

@property(nonatomic, retain)UIButton *button;
@property(nonatomic, retain)UIActivityIndicatorView *indicatorView;

@property(nonatomic, retain)id<SoundDownloader> soundDownloader;
@property(nonatomic, retain)AVAudioPlayer *player;

@end

@implementation PlaySoundView

@synthesize word;

@synthesize button;
@synthesize indicatorView;

@synthesize soundDownloader; 
@synthesize player;

- (void)dealloc
{
    self.word = nil;
    self.button = nil;
    self.indicatorView = nil;
    
    [soundDownloader cancel]; self.soundDownloader = nil;
    self.player.delegate = nil;
    self.player = nil;
    [super dealloc];
}

- (id)initWithWord:(NSString *)word_
{
    self = [self init];
    
    self.word = word_;
    
    return self;
}

- (id)init
{
    self = [self initWithFrame:CGRectZero];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setTitle:@"🔊" forState:UIControlStateHighlighted];
    [self.button setTitle:@"🔈" forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(onButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.button];
    
    self.indicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    [self addSubview:self.indicatorView];
    self.indicatorView.hidden = YES;
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.button.frame = self.bounds;
    self.indicatorView.frame = self.bounds;
}

- (void)setDownloading:(BOOL)downloading
{
    self.button.hidden = downloading;
    self.indicatorView.hidden = !downloading;
    if(!self.indicatorView.hidden){
        [self.indicatorView startAnimating];
    }else{
        [self.indicatorView stopAnimating];
    }
}

#pragma mark - events
- (void)onButtonTapped
{
    if(self.word.length != 0){
        [self.soundDownloader cancel];
        [self setDownloading:YES];
        self.soundDownloader = [SoundDownloader newDownloader];
        self.soundDownloader.delegate = self;
        [self.soundDownloader downloadWithWord:self.word];
    }
}

#pragma mark - SoundDownloaderDelegate
- (void)soundDownloader:(id)soundDownloader didSuccessWithSoundData:(NSData *)soundData
{
    [self setDownloading:NO];
    if(soundData.length != 0){
        self.player = [[[AVAudioPlayer alloc] initWithData:soundData error:nil] autorelease];
        self.player.delegate = self;
        [self.player play];
        self.button.enabled = NO;
    }
}

- (void)soundDownloader:(id)soundDownloader didFailWithError:(NSError *)error
{
    [self setDownloading:NO];
    NSLog(@"%@", error);
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    self.button.enabled = YES;
}

@end
