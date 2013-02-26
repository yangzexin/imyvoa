//
//  GlossaryManager.h
//  imyvoa
//
//  Created by yzx on 12-6-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GlossaryManager <NSObject>

- (BOOL)addWord:(NSString *)word;
- (void)removeWord:(NSString *)word;
- (NSArray *)wordList;

@end
