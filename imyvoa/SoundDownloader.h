//
//  SoundDownloader.h
//  imyvoa
//
//  Created by yangzexin on 12-9-24.
//
//

#import <Foundation/Foundation.h>

@protocol SoundDownloaderDelegate <NSObject>

@optional
- (void)soundDownloader:(id)soundDownloader didSuccessWithSoundData:(NSData *)soundData;
- (void)soundDownloader:(id)soundDownloader didFailWithError:(NSError *)error;

@end

@protocol SoundDownloader <NSObject>

@property(nonatomic, assign)id<SoundDownloaderDelegate> delegate;
- (void)downloadWithWord:(NSString *)word;
- (void)cancel;

@end

@interface SoundDownloader : NSObject <SoundDownloader>

+ (id<SoundDownloader>)newDownloader;

@end
