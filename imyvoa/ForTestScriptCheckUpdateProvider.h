//
//  ForTestScriptCheckUpdateProvider.h
//  imyvoa
//
//  Created by yzx on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScriptCheckUpdateProvider.h"
#import "YXTaskQueue.h"

@interface ForTestScriptCheckUpdateProvider : NSObject <ScriptCheckUpdateProvider, YXTaskExecutable> {
    id<ScriptCheckUpdateProviderDelegate> _delegate;
}

@property(nonatomic, assign)id<ScriptCheckUpdateProviderDelegate> delegate;

@end
