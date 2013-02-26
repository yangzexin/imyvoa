//
//  SoundListReader.h
//  imyvoa
//
//  Created by yangzexin on 12-9-28.
//
//

#import <Foundation/Foundation.h>

typedef void(^SoundListReaderCompletion) (void);

@protocol WordSoundListReader <NSObject>

- (void)playWithWordList:(NSArray *)wordList completion:(SoundListReaderCompletion)completion;
- (void)stop;
- (BOOL)playing;

@end

@interface WordSoundListReader : NSObject <WordSoundListReader>

@end
