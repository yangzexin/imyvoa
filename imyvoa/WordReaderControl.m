//
//  WordReaderControl.m
//  imyvoa
//
//  Created by yangzexin on 12-9-28.
//
//

#import "WordReaderControl.h"
#import "SVDelayController.h"

@interface RepeatTwiceWordReaderControl () <DelayControllerDelegate>

@property(nonatomic, assign)NSInteger readCount;
@property(nonatomic, assign)NSInteger repeatCount;
@property(nonatomic, retain)SVDelayController *delayController;

@end

@implementation RepeatTwiceWordReaderControl

@synthesize delegate;
@synthesize readCount;

- (void)dealloc
{
    [self.delayController cancel]; self.delayController = nil;
    [super dealloc];
}

- (id)init
{
    self = [self initWithRepeatCount:1];
    
    return self;
}

- (id)initWithRepeatCount:(NSInteger)count
{
    self = [super init];
    
    self.repeatCount = count;
    self.readCount = 0;
    
    return self;
}

- (void)askForRead
{
    [self.delayController cancel];
    if(readCount == _repeatCount){
        self.delayController = [[[SVDelayController alloc] initWithInterval:1.0f] autorelease];
        self.delayController.delegate = self;
        self.delayController.tag = 1;
        [self.delayController start];
    }else{
        self.delayController = [[[SVDelayController alloc] initWithInterval:0.50f] autorelease];
        self.delayController.delegate = self;
        self.delayController.tag = 2;
        [self.delayController start];
    }
    ++readCount;
}

- (void)notifyDidFinishPlay
{
    if([self.delegate respondsToSelector:@selector(wordReaderControlDidFinishPlay:)]){
        [self.delegate wordReaderControlDidFinishPlay:self];
    }
}

- (void)notifyWantToPlay
{
    if([self.delegate respondsToSelector:@selector(wordReaderControlWantToPlay:)]){
        [self.delegate wordReaderControlWantToPlay:self];
    }
}

#pragma mark - DelayControllerDelegate
- (void)delayControllerDidFinishDelay:(SVDelayController *)controller
{
    if(controller.tag == 1){
        [self notifyDidFinishPlay];
    }else if(controller.tag == 2){
        [self notifyWantToPlay];
    }
}

@end
