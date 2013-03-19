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

@property(nonatomic, retain)UIImageView *backgroundImageView;

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

@end
