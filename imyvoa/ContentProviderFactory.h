//
//  ContentProviderFactory.h
//  imyvoa
//
//  Created by yangzexin on 2/11/13.
//
//

#import <Foundation/Foundation.h>
#import "VoaNewsDetailProvider.h"
#import "VoaNewsListProvider.h"

@interface ContentProviderFactory : NSObject

+ (id<VoaNewsDetailProvider>)newsDetailProvider;
+ (id<VoaNewsListProvider>)newsListProvider;

@end
