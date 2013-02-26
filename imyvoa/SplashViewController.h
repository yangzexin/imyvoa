//
//  SplashViewController.h
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SplashViewController;
@class TaskQueue;

@protocol SplashViewControllerDelegate <NSObject>

@optional
- (void)splashViewControllerDidFinished:(SplashViewController *)splashVC;

@end

@interface SplashViewController : UIViewController {
    id<SplashViewControllerDelegate> _delegate;
    TaskQueue *_taskQueue;
}

@property(nonatomic, assign)id<SplashViewControllerDelegate> delegate;

@end
