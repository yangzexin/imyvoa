//
//  Utils.h
//  imyvoa
//
//  Created by gewara on 12-6-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (NSString *)dateStringFromNewsItemTitle:(NSString *)title;
+ (NSString *)formattedDateStringFromNewsItemTitle:(NSString *)title;
+ (NSString *)newsTitleFromNewsItemTitle:(NSString *)title;

+ (NSString *)stripHTMLTags:(NSString *)str;

@end
