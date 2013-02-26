//
//  ViewHTMLViewController.h
//  imyvoa
//
//  Created by gewara on 12-5-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dictionary.h"
#import "WebViewStack.h"

@class DictionaryViewController;

@protocol DictionaryViewControllerDelegate <NSObject>

@optional
- (BOOL)dictionaryViewController:(DictionaryViewController *)dictVC bookmarkWord:(NSString *)word;

@end

@interface DictionaryViewController : UINavigationController <DictionaryDelegate> {
    id<DictionaryViewControllerDelegate> _dictionaryViewControllerDelegate;
    
    UIViewController *_dictVC;
    UIWebView *_webView;
    UIBarButtonItem *_backBtn;
    UIBarButtonItem *_forwardBtn;
    UIBarButtonItem *_bookmarkBtn;
    
    id<Dictionary> _dictionary;
    
    id<WebViewStack> _webViewStack;
}

@property(nonatomic, assign)id<DictionaryViewControllerDelegate> dictionaryViewControllerDelegate;

+ (DictionaryViewController *)sharedInstance;
- (void)query:(NSString *)word;

@end
