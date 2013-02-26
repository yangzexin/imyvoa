//
//  SplashViewController.m
//  imyvoa
//
//  Created by gewara on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SplashViewController.h"
#import "TaskQueue.h"

@interface SplashViewController () <TaskQueueDelegate>

@property(nonatomic, retain)TaskQueue *taskQueue;

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
    
    self.taskQueue = [TaskQueue newTaskQueue];
    self.taskQueue.delegate = self;
    
    [self.taskQueue start];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - private methods

#pragma mark - TaskQueueDelegate
- (void)taskQueueDidStarted:(TaskQueue *)taskQueue
{
    [self setWaiting:YES];
}

- (void)taskQueueDidInterrupted:(TaskQueue *)taskQueue
{
    [self alert:@"加载失败"];
}

- (void)taskQueueDidFinished:(TaskQueue *)taskQueue
{
    [self setWaiting:NO];
    if([self.delegate respondsToSelector:@selector(splashViewControllerDidFinished:)]){
        [self.delegate splashViewControllerDidFinished:self];
    }
}

- (void)taskQueue:(TaskQueue *)taskQueue willStartTask:(id<TaskExecutable>)task
{
}

@end
