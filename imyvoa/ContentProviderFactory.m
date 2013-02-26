//
//  ContentProviderFactory.m
//  imyvoa
//
//  Created by yangzexin on 2/11/13.
//
//

#import "ContentProviderFactory.h"
#import "LuaVoaNewsContentProvider.h"
#import "LuaVoaNewsListProvider.h"

@implementation ContentProviderFactory

+ (id<VoaNewsDetailProvider>)newsDetailProvider
{
    static id instance = nil;
    if(instance == nil){
        instance = [LuaVoaNewsContentProvider new];
    }
    return instance;
}

+ (id<VoaNewsListProvider>)newsListProvider
{
    static id instance = nil;
    if(instance == nil){
        instance = [LuaVoaNewsListProvider new];
    }
    return instance;
}

@end
