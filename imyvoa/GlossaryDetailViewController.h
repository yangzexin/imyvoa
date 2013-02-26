//
//  GlossaryDetailViewController.h
//  imyvoa
//
//  Created by gewara on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"
#import "Dictionary.h"
#import "GlossaryManager.h"

@interface GlossaryDetailViewController : BaseViewController {
    NSString *_word;
    id<Dictionary> _dictionary;
    
    UIWebView *_webView;
}

@property(nonatomic, retain)id<GlossaryManager> glossaryManager;

- (id)initWithWord:(NSString *)word;

@end
