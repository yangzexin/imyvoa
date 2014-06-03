//
//  SoundDownloader.m
//  imyvoa
//
//  Created by yangzexin on 12-9-24.
//
//

#import "SoundDownloader.h"
#import "SoundURLMaker.h"
#import "SVHTTPDownloader.h"
#import "SVKeyValueManager.h"
#import "SVDatabaseKeyValueManager.h"
#import "SVEncryptUtils.h"

@interface SoundDownloader () <SVHTTPDownloaderDelegate>

@property(nonatomic, copy)NSString *word;
@property(nonatomic, retain)id<SoundURLMaker> soundURLMaker;
@property(nonatomic, retain)SVHTTPDownloader *downloader;
@property(nonatomic, retain)id<SVKeyValueManager> wordSoundCache;

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
    self.wordSoundCache = [[[SVDatabaseKeyValueManager alloc] initWithDBName:@"word_sound" atFolder:[[SharedResource sharedInstance] cachePath]] autorelease];
    
    return self;
}

- (NSString *)tmpSoundPath
{
    return [NSString stringWithFormat:@"%@/tmp/tmp.mp3", NSHomeDirectory()];
}

- (void)downloadWithWord:(NSString *)word_
{
    self.word = word_;
    NSString *encodeWord = [SVEncryptUtils hexStringByEncodingString:word];
    NSString *cache = [self.wordSoundCache valueForKey:encodeWord];
    if(cache){
        NSData *data = [SVEncryptUtils dataByDecodingHexString:cache];
        [self notifySuccessWithData:data];
    }else{
        NSString *soundURL = [self.soundURLMaker makeURLStringForWord:word];
        [self.downloader cancel];
        self.downloader = [[[SVHTTPDownloader alloc] initWithURLString:soundURL saveToPath:[self tmpSoundPath]] autorelease];
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
- (void)HTTPDownloader:(SVHTTPDownloader *)downloader didErrored:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(soundDownloader:didFailWithError:)]){
        [self.delegate soundDownloader:self didFailWithError:error];
    }
}

- (void)HTTPDownloaderDidFinished:(SVHTTPDownloader *)downloader_
{
    NSData *soudData = [NSData dataWithContentsOfFile:[self tmpSoundPath]];
    if(soudData.length != 0){
        NSString *cache = [SVEncryptUtils hexStringByEncodingData:soudData];
        [self.wordSoundCache setValue:cache forKey:[SVEncryptUtils hexStringByEncodingString:self.word]];
        [self notifySuccessWithData:soudData];
    }else{
        [self HTTPDownloader:downloader_ didErrored:[NSError errorWithDomain:@"SoundDownloader"
                                                                       code:-1
                                                                   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Download Failure",
                                                                             NSLocalizedDescriptionKey, nil]]];
    }
}

@end
