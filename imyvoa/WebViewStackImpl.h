//
//  WebViewStackImpl.h
//  imyvoa
//
//  Created by yzx on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewStack.h"
#import "SVKeyValueManager.h"

@interface WebViewStackImpl : NSObject <WebViewStack> {
    NSMutableArray *_keyList;
    NSInteger _pointerIndex;
    
    id<SVKeyValueManager> _keyValueCache;
}

@end
