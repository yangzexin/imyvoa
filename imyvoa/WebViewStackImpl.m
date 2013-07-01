//
//  WebViewStackImpl.m
//  imyvoa
//
//  Created by yzx on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WebViewStackImpl.h"
#import "YXDatabaseKeyValueManager.h"

@interface WebViewStackImpl ()

@property(nonatomic, retain)NSMutableArray *keyList;
@property(nonatomic)NSInteger pointerIndex;

@property(nonatomic, retain)id<YXKeyValueManager> keyValueCache;

@end

@implementation WebViewStackImpl

@synthesize keyList = _keyList;
@synthesize pointerIndex = _pointerIndex;

@synthesize keyValueCache = _keyValueCache;

- (void)dealloc
{
    [_keyList release];
    
    [_keyValueCache release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.keyList = [NSMutableArray array];
    self.pointerIndex = -1;
    
    self.keyValueCache = [[[YXDatabaseKeyValueManager alloc] initWithDBName:@"web view stack" atFolder:[[SharedResource sharedInstance] cachePath]] autorelease];
    [self.keyValueCache clear];
    
    return self;
}

- (void)push:(NSString *)value
{
    [self interrupt];
    
    NSString *key = [NSString stringWithFormat:@"%f", [[[[NSDate alloc] init] autorelease] timeIntervalSinceReferenceDate]];
    [self.keyValueCache setValue:value forKey:key];
    [self.keyList addObject:key];
    ++self.pointerIndex;
}

- (void)pop
{
    if([self canBack]){
        --self.pointerIndex;
    }else{
        self.pointerIndex = -1;
    }
    [self interrupt];
}

- (NSString *)peek
{
    if(self.pointerIndex != -1){
        NSString *key = [self.keyList objectAtIndex:self.pointerIndex];
        
        return [self.keyValueCache valueForKey:key];
    }
    
    return nil;
}

- (BOOL)canBack
{
    return self.pointerIndex != 0 && self.pointerIndex != -1;
}

- (BOOL)canForward
{
    return self.pointerIndex != self.keyList.count - 1 && self.pointerIndex != -1;
}

- (NSString *)back
{
    if([self canBack]){
        --self.pointerIndex;
        return [self peek];
    }
    return nil;
}

- (NSString *)forward
{
    if([self canForward]){
        ++self.pointerIndex;
        return [self peek];
    }
    return nil;
}

- (void)interrupt
{
    NSInteger remainCount = self.pointerIndex + 1;
    while(self.keyList.count > remainCount){
        [self.keyList removeObjectAtIndex:self.keyList.count - 1];
    }
}

- (void)movePointerToEnd
{
    self.pointerIndex = self.keyList.count - 1;
}

@end
