//
//  AllGlossaryViewController.m
//  imyvoa
//
//  Created by yangzexin on 10/10/12.
//
//

#import "AllGlossaryViewController.h"
#import "AllGlossaryManager.h"

@implementation AllGlossaryViewController

- (id)init
{
    self = [super initWithGlossaryManager:[AllGlossaryManager sharedManager]];
    
    return self;
}

@end
