//
//  SplashViewController.m
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SplashViewController.h"
#import "SVTaskQueue.h"
#import "SVApplicationScriptBundle.h"
#import "SVOnlineAppBundle.h"
#import "SVScriptBundleRepository.h"
#import "SVApp.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

@synthesize delegate = _delegate;

- (void)dealloc
{
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setLoading:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        id<SVScriptBundle> scriptBundle = [[[SVOnlineAppBundle alloc] initWithURL:
                                            [NSURL URLWithString:@"http://imyvoaspecial.googlecode.com/files/com.yzx.imyvoa.pkg"]] autorelease];
        if(scriptBundle){
            NSLog(@"download scrit success");
            [[SVScriptBundleRepository defaultRespository] repositScriptBundle:scriptBundle];
        }else{
            NSLog(@"download script failed, try to get script bundle from local respository");
            scriptBundle = [[SVScriptBundleRepository defaultRespository] scriptBundleWithBundleId:@"com.yzx.imyvoa"];
        }
        if(!scriptBundle){
            NSLog(@"cannot find script bundle from local repository, use application script bundle");
            scriptBundle = [[[SVApplicationScriptBundle alloc] initWithMainScriptName:@"main"] autorelease];
        }
        SVApp *app = [[[SVApp alloc] initWithScriptBundle:scriptBundle] autorelease];
        [SharedResource sharedInstance].scriptApp = app;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self setLoading:NO];
            if([self.delegate respondsToSelector:@selector(splashViewControllerDidFinished:)]){
                [self.delegate splashViewControllerDidFinished:self];
            }
        });
    });
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

@end
