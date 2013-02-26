//
//  LuaHelper.m
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LuaHelper.h"
#import "LuaInvoker.h"

@interface LuaHelper ()

@property(nonatomic, retain)LuaInvoker *luaInvoker;

@end

@implementation LuaHelper

@dynamic script;

@synthesize luaInvoker = _luaInvoker;

+ (LuaHelper *)sharedInstance
{
    static LuaHelper *instance;
    @synchronized(instance){
        if(instance == nil){
            instance = [[LuaHelper alloc] init];
        }
    }
    
    return instance;
}

- (void)dealloc
{
    [_luaInvoker release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.luaInvoker = [[[LuaInvoker alloc] init] autorelease];
    
    return self;
}

- (oneway void)release
{
    
}

- (id)retain
{
    return self;
}

- (id)autorelease
{
    return self;
}

- (void)setScript:(NSString *)script
{
    self.luaInvoker.script = script;
}

- (NSString *)script
{
    return self.luaInvoker.script;
}

- (NSString *)invokeProperty:(NSString *)methodName
{
    return [self.luaInvoker invokeProperty:methodName];
}
- (NSString *)invokeMethodWithName:(NSString *)methodName paramValue:(NSString *)paramValue
{
    return [self.luaInvoker invokeMethodWithName:methodName paramValue:paramValue];
}

@end
