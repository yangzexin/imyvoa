//
//  DBGlossaryManager.h
//  imyvoa
//
//  Created by yzx on 12-6-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVKeyValueManager.h"
#import "GlossaryManager.h"

@interface DBGlossaryManager : NSObject <GlossaryManager> {
    id<SVKeyValueManager> _glossaryLibrary;
}

- (id)initWithIdentifier:(NSString *)identifier;

@end
