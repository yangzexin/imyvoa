//
//  WordReaderControl.h
//  imyvoa
//
//  Created by yangzexin on 12-9-28.
//
//

#import <Foundation/Foundation.h>

@protocol WordReaderControlDelegate <NSObject>

- (void)wordReaderControlWantToPlay:(id)control;
- (void)wordReaderControlDidFinishPlay:(id)control;

@end

@protocol WordReaderControl <NSObject>

@property(nonatomic, assign)id<WordReaderControlDelegate> delegate;
- (void)askForRead;

@end

@interface RepeatTwiceWordReaderControl : NSObject <WordReaderControl>

- (id)initWithRepeatCount:(NSInteger)count;

@end
