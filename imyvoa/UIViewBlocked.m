//
//  UIViewBlocked.m
//  imyvoa
//
//  Created by yangzexin on 13-2-4.
//
//

#import "UIViewBlocked.h"

@implementation UIViewBlocked

- (void)dealloc
{
    self.layoutSubviewsBlock = nil;
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if(self.layoutSubviewsBlock){
        self.layoutSubviewsBlock();
    }
}

@end
