//
//  SoundDownloader.m
//  imyvoa
//
//  Created by yangzexin on 12-9-24.
//
//

#import "SoundDownloader.h"
#import "SoundURLMaker.h"
#import "HTTPDownloader.h"
#import "KeyValueManager.h"
#import "DataBaseKeyValueManager.h"
#import "CodeUtils.h"

@interface SoundDownloader () <HTTPDownloaderDelegate>

@property(nonatomic, copy)NSString *word;
@property(nonatomic, retain)id<SoundURLMaker> soundURLMaker;
@property(nonatomic, retain)HTTPDownloader *downloader;
@property(nonatomic, retain)id<KeyValueManager> wordSoundCache;

@end

@implementation SoundDownloader

@synthesize delegate;

@synthesize word;
@synthesize soundURLMaker;
@synthesize downloader;
@synthesize wordSoundCache;

+ (id<SoundDownloader>)newDownloader
{
    return [[[SoundDownloader alloc] init] autorelease];
}

- (void)dealloc
{
    self.word = nil;
    self.soundURLMaker = nil;
    [self.downloader cancel]; self.downloader = nil;
    self.wordSoundCache = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.soundURLMaker = [[[SoundURLMaker alloc] init] autorelease];
    self.wordSoundCache = [[[DataBaseKeyValueManager alloc] initWithDBName:@"word_sound" atFolder:[[SharedResource sharedInstance] cachePath]] autorelease];
    
    return self;
}

- (NSString *)tmpSoundPath
{
    return [NSString stringWithFormat:@"%@/tmp/tmp.mp3", NSHomeDirectory()];
}

- (void)downloadWithWord:(NSString *)word_
{
    self.word = word_;
    NSString *encodeWord = [CodeUtils encodeWithString:word];
    NSString *cache = [self.wordSoundCache valueForKey:encodeWord];
    if(cache){
        NSData *data = [CodeUtils dataDecodedWithString:cache];
        [self notifySuccessWithData:data];
    }else{
        NSString *soundURL = [self.soundURLMaker makeURLStringForWord:word];
        [self.downloader cancel];
        self.downloader = [[[HTTPDownloader alloc] initWithURLString:soundURL saveToPath:[self tmpSoundPath]] autorelease];
        self.downloader.delegate = self;
        [self.downloader startDownload];
    }
}

- (void)cancel
{
    self.delegate = nil;
    [self.downloader cancel]; self.downloader = nil;
}

- (void)notifySuccessWithData:(NSData *)soudData
{
    if([self.delegate respondsToSelector:@selector(soundDownloader:didSuccessWithSoundData:)]){
        [self.delegate soundDownloader:self didSuccessWithSoundData:soudData];
    }
}

#pragma mark - HTTPDownloaderDelegate
- (void)HTTPDownloader:(HTTPDownloader *)downloader didErrored:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(soundDownloader:didFailWithError:)]){
        [self.delegate soundDownloader:self didFailWithError:error];
    }
}

- (void)HTTPDownloaderDidFinished:(HTTPDownloader *)downloader_
{
    NSData *soudData = [NSData dataWithContentsOfFile:[self tmpSoundPath]];
    if(soudData.length != 0){
        NSString *cache = [CodeUtils encodeWithData:soudData];
        [self.wordSoundCache setValue:cache forKey:[CodeUtils encodeWithString:self.word]];
        [self notifySuccessWithData:soudData];
    }else{
        [self HTTPDownloader:downloader_ didErrored:[NSError errorWithDomain:@"SoundDownloader"
                                                                       code:-1
                                                                   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Download Failure",
                                                                             NSLocalizedDescriptionKey, nil]]];
    }
}

@end
