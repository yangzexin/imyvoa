//
//  WordReader.h
//  imyvoa
//
//  Created by yangzexin on 12-9-28.
//
//

#import <Foundation/Foundation.h>
#import "SVProviderPool.h"
#import "WordReaderControl.h"

typedef void(^WordReaderCompletion) (void);

@protocol WordReader <ProviderPoolable>

- (void)readWord:(NSString *)word wordReaderControl:(id<WordReaderControl>)wordReaderControl completion:(WordReaderCompletion)completion;
- (void)stop;

@end

@interface WordReader : NSObject <WordReader>

@end
