//
//  DictionaryFactory.h
//  imyvoa
//
//  Created by yangzexin on 13-2-22.
//
//

#import <Foundation/Foundation.h>

@protocol Dictionary;

@interface DictionaryFactory : NSObject

+ (id<Dictionary>)defaultDictionary;

@end
