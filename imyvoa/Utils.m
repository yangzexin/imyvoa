//
//  Utils.m
//  imyvoa
//
//  Created by gewara on 12-6-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "YXCommonUtils.h"

@implementation Utils

+ (NSString *)dateStringFromNewsItemTitle:(NSString *)title
{
    NSRange range = [title rangeOfString:@"(" options:NSBackwardsSearch];
    if(range.length != 0){
        NSRange endRange = [title rangeOfString:@")" options:NSBackwardsSearch];
        if(endRange.length != 0 && endRange.location > range.location){
            ++range.location;
            return [title substringWithRange:NSMakeRange(range.location, endRange.location - range.location)];
        }
    }
    return nil;
}

+ (NSString *)formattedDateStringFromNewsItemTitle:(NSString *)title
{
    NSString *dateString = [self dateStringFromNewsItemTitle:title];
    if(dateString){
        NSArray *comps = [dateString componentsSeparatedByString:@"-"];
        if(comps.count == 3){
            NSString *year = [comps objectAtIndex:0];
            NSString *month = [comps objectAtIndex:1];
            NSString *day = [comps objectAtIndex:2];
            if(year.length == 4){
                return [NSString stringWithFormat:@"%@-%@-%@", year, 
                        [YXCommonUtils formatNumber:[month intValue]], 
                        [YXCommonUtils formatNumber:[day intValue]]];
            }
        }
    }
    return nil;
}

+ (NSString *)newsTitleFromNewsItemTitle:(NSString *)title
{
    NSRange range = [title rangeOfString:@"(" options:NSBackwardsSearch];
    if(range.length != 0){
        return [title substringWithRange:NSMakeRange(0, range.location)];
    }
    return nil;
}

+ (NSString *)stripHTMLTags:(NSString *)str
{
    NSMutableString *ms = [NSMutableString string];
    NSScanner *scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped:nil];
    NSString *s = nil;
    while (![scanner isAtEnd])
    {
        [scanner scanUpToString:@"<" intoString:&s];
        if (s != nil)
            [ms appendString:s];
        [scanner scanUpToString:@">" intoString:NULL];
        if (![scanner isAtEnd])
            [scanner setScanLocation:[scanner scanLocation]+1];
        s = nil;
    }
    NSMutableDictionary *replaceSet = [NSMutableDictionary dictionary];
    [replaceSet setObject:@"" forKey:@"&hellip;"];
    [replaceSet setObject:@" " forKey:@"&nbsp;"];
    [replaceSet setObject:@"" forKey:@"&ldquo;"];
    [replaceSet setObject:@"" forKey:@"&rdquo;"];
    [replaceSet setObject:@"\"" forKey:@"&#39;"];
    [replaceSet setObject:@"" forKey:@"&mdash;"];
    [replaceSet setObject:@"" forKey:@"&amp;"];
    [replaceSet setObject:@"" forKey:@"&rsquo;"];
    [replaceSet setObject:@"\"" forKey:@"&quot;"];
    [replaceSet setObject:@"·" forKey:@"&middot;"];
    
    NSString *result = ms;
    NSArray *allKeys = [replaceSet allKeys];
    for(NSString *key in allKeys){
        result = [result stringByReplacingOccurrencesOfString:key withString:[replaceSet objectForKey:key]];
    }
    
    return result;
}

@end
