//
//  AboutUsViewController.m
//  imyvoa
//
//  Created by yangzexin on 5/20/13.
//
//

#import "AboutUsViewController.h"

@implementation AboutUsViewController

- (void)loadView
{
    [super loadView];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"button" forState:UIControlStateNormal];
    button.frame = CGRectMake(10, 10, 200, 30);
    [self.view addSubview:button];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.view.backgroundColor = [UIColor clearColor];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

@end
