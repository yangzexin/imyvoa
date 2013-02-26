//
//  UIViewBlocked.h
//  imyvoa
//
//  Created by yangzexin on 13-2-4.
//
//

#import <Foundation/Foundation.h>

@interface UIViewBlocked : UIView

@property(nonatomic, copy)void(^layoutSubviewsBlock)();

@end
