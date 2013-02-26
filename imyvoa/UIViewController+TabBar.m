//
//  UIViewController+TabBar.m
//  VOA
//
//  Created by yangzexin on 12-2-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+TabBar.h"

@implementation UIViewController (TabBar)

- (void)hideTabBarAnimationDidStop
{
    [self.tabBarController.tabBar setHidden:YES];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)hideTabBar:(BOOL)hide animated:(BOOL)animated
{
    UIView *tabBar = self.tabBarController.tabBar;
    if(tabBar){
        if(animated){
            CGFloat tabBarHeight = tabBar.frame.size.height;
            CGFloat currentY = 0;
            CGFloat targetY = 0;
            CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
            if(hide){
                currentY = screenHeight - tabBarHeight;
                targetY = screenHeight;
            }else{
                currentY = screenHeight;
                targetY = screenHeight - tabBarHeight;
            }
            CGRect tmpFrame = tabBar.frame;
            //tmpFrame.origin.y = currentY;
            //tabBar.frame = tmpFrame;
            tmpFrame.origin.y = targetY;
            
            if(!hide){
                [tabBar setHidden:NO];
            }
            [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
            [UIView setAnimationDuration:0.47f];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            if(hide){
                [UIView setAnimationDidStopSelector:@selector(hideTabBarAnimationDidStop)];
            }
            tabBar.frame = tmpFrame;
            [UIView commitAnimations];
        }else{
            [tabBar setHidden:hide];
        }
    }
}

@end
