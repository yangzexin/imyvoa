//
//  DictionaryFactory.m
//  imyvoa
//
//  Created by yangzexin on 13-2-22.
//
//

#import "DictionaryFactory.h"
#import "OnlineDictionary.h"

@implementation DictionaryFactory

+ (id<Dictionary>)defaultDictionary
{
    static id<Dictionary> dictionary = nil;
    
    @synchronized(dictionary){
        if(dictionary == nil){
            dictionary = [[OnlineDictionary alloc] init];
        }
    }
    
    return dictionary;
}

@end
