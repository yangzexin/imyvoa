//
//  ScriptUpdateProvider.h
//  imyvoa
//
//  Created by yzx on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentProvider.h"

@protocol ScriptCheckUpdateProvider <ContentProvider>

- (void)checkUpdateWithLocalVersionCode:(NSString *)versionCode;

@end

@protocol ScriptCheckUpdateProviderDelegate <NSObject>

@optional
- (void)scriptCheckUpdateProvider:(id)provider didSucceedWithResult:(BOOL)hasNewVersion;
- (void)ScriptCheckUpdateProvider:(id)provider didFailedWithError:(NSError *)error;

@end