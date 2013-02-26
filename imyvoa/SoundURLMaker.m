//
//  SoundURLMaker.m
//  imyvoa
//
//  Created by yangzexin on 12-9-24.
//
//

#import "SoundURLMaker.h"

@implementation SoundURLMaker

- (NSString *)makeURLStringForWord:(NSString *)word
{
    NSString *prefixURLString = @"http://tts.yeshj.com/uk/s/";
    word = [word stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    return [NSString stringWithFormat:@"%@%@", prefixURLString, word];
}

@end
