//
//  SoundCache.m
//  imyvoa
//
//  Created by gewara on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SoundCache.h"
#import "SVDatabaseKeyValueManager.h"
#import "SVEncryptUtils.h"
#import "AppDelegate.h"

@interface SoundCache ()

@property(nonatomic, retain)id<SVKeyValueManager> cache;

@end

@implementation SoundCache

@synthesize cache = _cache;

+ (SoundCache *)sharedInstance
{
    static SoundCache *instance = nil;
    @synchronized(instance){
        if(instance == nil){
            instance = [[SoundCache alloc] init];
        }
    }
    
    return instance;
}

+ (NSString *)soundCachePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [[[AppDelegate sharedAppDelegate] cachePath] stringByAppendingPathComponent:@"sounds"];
    if(![fileManager fileExistsAtPath:path]){
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return path;
}

- (void)dealloc
{
    [_cache release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.cache = [[[SVDatabaseKeyValueManager alloc] initWithDBName:@"soud_url_file_path_cache" atFolder:[[AppDelegate sharedAppDelegate] cachePath]] autorelease];
    
    return self;
}

- (void)addSoundURLString:(NSString *)sounURLString atFilePath:(NSString *)filePath
{
    [self.cache setValue:filePath forKey:[SVEncryptUtils hexStringByMD5EncryptingString:sounURLString]];
}

- (NSString *)filePathForSoundURLString:(NSString *)soundURLString
{
    NSString *soundPath = [self.cache valueForKey:[SVEncryptUtils hexStringByMD5EncryptingString:soundURLString]];
    
    if([soundPath length] != 0 && [[NSFileManager defaultManager] fileExistsAtPath:soundPath]){
        return soundPath;
    }
    return nil;
}

- (void)removeSoundCacheForSoundURLString:(NSString *)soudURLString
{
    NSString *filePath = [self filePathForSoundURLString:soudURLString];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

@end
