//
//  FromGoogleScriptUpdateProvider.h
//  imyvoa
//
//  Created by yzx on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScriptUpdateProvider.h"

@interface FromGoogleScriptUpdateProvider : NSObject <ScriptUpdateProvider> {
    id<ScriptUpdateProviderDelegate> _delegate;
}

@property(nonatomic, assign)id<ScriptUpdateProviderDelegate> delegate;

@end
