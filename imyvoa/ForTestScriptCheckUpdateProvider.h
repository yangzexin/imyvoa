//
//  ForTestScriptCheckUpdateProvider.h
//  imyvoa
//
//  Created by yzx on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScriptCheckUpdateProvider.h"
#import "TaskQueue.h"

@interface ForTestScriptCheckUpdateProvider : NSObject <ScriptCheckUpdateProvider, TaskExecutable> {
    id<ScriptCheckUpdateProviderDelegate> _delegate;
}

@property(nonatomic, assign)id<ScriptCheckUpdateProviderDelegate> delegate;

@end
