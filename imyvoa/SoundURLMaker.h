//
//  SoundURLMaker.h
//  imyvoa
//
//  Created by yangzexin on 12-9-24.
//
//

#import <Foundation/Foundation.h>

@protocol SoundURLMaker <NSObject>

@optional
- (NSString *)makeURLStringForWord:(NSString *)word;

@end

@interface SoundURLMaker : NSObject <SoundURLMaker>

@end
