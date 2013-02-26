//
//  GoogleCodeScriptProvider.h
//  imyvoa
//
//  Created by yzx on 12-6-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LuaScriptProvider.h"
#import "ScriptCheckUpdateProvider.h"
#import "ScriptUpdateProvider.h"

@interface GoogleCodeScriptProvider : NSObject <LuaScriptProvider> {
    id<LuaScriptProviderDelegate> _delegate;
    
    
}

@property(nonatomic, assign)id<LuaScriptProviderDelegate> delegate;

@end
