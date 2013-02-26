//
//  GlossaryLibraryViewController.h
//  imyvoa
//
//  Created by yzx on 12-6-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"
#import "GlossaryManager.h"

@interface GlossaryLibraryViewController : BaseViewController {
    id<GlossaryManager> _glossaryManager;
    NSArray *_glossaryList;
    
    UITableView *_tableView;
}

- (id)initWithGlossaryManager:(id<GlossaryManager>)glossaryManager;

@end
