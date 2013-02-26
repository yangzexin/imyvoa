//
//  AppDelegate.h
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dictionary.h"

@class DictionaryViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UINavigationController *_newsListNC;
    UINavigationController *_localNewsListNC;
}

@property (strong, nonatomic) UIWindow *window;

@end
