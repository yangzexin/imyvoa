//
//  TutorialableNavigationController.m
//  imyvoa
//
//  Created by yangzexin on 13-3-13.
//
//

#import "TutorialableNavigationController.h"
#import "TutorialManager.h"
#import "SVDelayControl.h"

@implementation TutorialableNavigationController

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[[[SVDelayControl alloc] initWithInterval:0.30f completion:^{
        [[TutorialManager defaultManager] showTutorialWithPageName:NSStringFromClass(viewController.class)];
    }] autorelease] start];
    [super pushViewController:viewController animated:animated];
}

@end
