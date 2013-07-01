//
//  SoundCache.h
//  imyvoa
//
//  Created by gewara on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXKeyValueManager.h"

@interface SoundCache : NSObject {
    id<YXKeyValueManager> _cache;
}

+ (SoundCache *)sharedInstance;

+ (NSString *)soundCachePath;

- (void)addSoundURLString:(NSString *)sounURLString atFilePath:(NSString *)filePath;
- (NSString *)filePathForSoundURLString:(NSString *)soundURLString;
- (void)removeSoundCacheForSoundURLString:(NSString *)soudURLString;

@end
