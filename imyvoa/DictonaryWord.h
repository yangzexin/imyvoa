//
//  DictonaryWord.h
//  imyvoa
//
//  Created by yzx on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictonaryWord : NSObject {
    NSString *word;
    NSString *definition;
}

@property(nonatomic, retain)NSString *word;
@property(nonatomic, retain)NSString *definition;

@end
