//
//  BaseViewController.h
//  VOA
//
//  Created by yangzexin on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVProviderPool.h"

@interface BaseViewController : UIViewController {
@private
    NSString *_customTitle;
    UILabel *_titleLabel;
    
}

- (void)addProviderToPool:(id<SVProviderPoolable>)provider;
- (UIView *)customTitleView;

@end
