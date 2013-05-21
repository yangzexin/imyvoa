//
//  TestVC.m
//  imyvoa
//
//  Created by yangzexin on 5/21/13.
//
//

#import "TestVC.h"

@implementation TestVC

- (void)loadView
{
    [super loadView];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20, 20, 100, 30);
    [button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonTapped
{
    TestVC *vc = [[[TestVC alloc] init] autorelease];
    vc.title = @"testset";
    [self presentTransparentModalViewController:vc animated:YES completion:^{
        
    }];
}

@end
