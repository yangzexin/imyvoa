//
//  AllGlossaryManager.h
//  imyvoa
//
//  Created by yangzexin on 10/10/12.
//
//

#import <Foundation/Foundation.h>
#import "GlossaryManager.h"

@interface AllGlossaryManager : NSObject <GlossaryManager>

+ (id)sharedManager;

@end
