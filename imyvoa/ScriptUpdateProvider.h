//
//  ScriptUpdateProvider.h
//  imyvoa
//
//  Created by yzx on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentProvider.h"

@protocol ScriptUpdateProvider <ContentProvider>

- (void)update;

@end

@protocol ScriptUpdateProviderDelegate <NSObject>

@optional
- (void)scriptUpdateProvider:(id)provider didSucceedWithResult:(NSString *)script;
- (void)scriptUpdateProvider:(id)provider didFailedWithError:(NSError *)error;

@end
