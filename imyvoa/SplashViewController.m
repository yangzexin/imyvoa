//
//  SplashViewController.m
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SplashViewController.h"
#import "SVTaskQueue.h"

@interface SplashViewController () <SVTaskQueueDelegate>

@property(nonatomic, retain)SVTaskQueue *taskQueue;

@end

@implementation SplashViewController

@synthesize delegate = _delegate;
@synthesize taskQueue = _taskQueue;

- (void)dealloc
{
    [_taskQueue release];
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
    
    self.taskQueue = [SVTaskQueue newTaskQueue];
    self.taskQueue.delegate = self;
    
    [self.taskQueue start];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - private methods

#pragma mark - TaskQueueDelegate
- (void)taskQueueDidStarted:(SVTaskQueue *)taskQueue
{
    [self setWaiting:YES];
}

- (void)taskQueueDidInterrupted:(SVTaskQueue *)taskQueue
{
    [self alert:@"加载失败"];
}

- (void)taskQueueDidFinished:(SVTaskQueue *)taskQueue
{
    [self setWaiting:NO];
    if([self.delegate respondsToSelector:@selector(splashViewControllerDidFinished:)]){
        [self.delegate splashViewControllerDidFinished:self];
    }
}

- (void)taskQueue:(SVTaskQueue *)taskQueue willStartTask:(id<SVTaskExecutable>)task
{
}

@end
