//
//  WebViewStack.h
//  imyvoa
//
//  Created by yzx on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WebViewStack <NSObject>

- (void)push:(NSString *)value;
- (void)pop;
- (NSString *)peek;
- (BOOL)canBack;
- (BOOL)canForward;
- (NSString *)back;
- (NSString *)forward;
- (void)movePointerToEnd;

@end
