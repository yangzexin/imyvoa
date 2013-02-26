//
//  LuaHelper.h
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LuaInvoker;

@interface LuaHelper : NSObject {
@private
    LuaInvoker *_luaInvoker;
}

@property(nonatomic, copy)NSString *script;

+ (LuaHelper *)sharedInstance;

- (NSString *)invokeProperty:(NSString *)methodName;
- (NSString *)invokeMethodWithName:(NSString *)methodName paramValue:(NSString *)paramValue;

@end
