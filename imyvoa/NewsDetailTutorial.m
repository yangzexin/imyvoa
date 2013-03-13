//
//  NewsDetailTutorial.m
//  imyvoa
//
//  Created by yangzexin on 13-3-13.
//
//

#import "NewsDetailTutorial.h"
#import "SVAlertDialog.h"

@implementation NewsDetailTutorial

- (void)show
{
    [SVAlertDialog showWithTitle:@"教程"
                         message:@"长按文本选中单词之后，可以使用在线字典查询单词"
                      completion:nil
               cancelButtonTitle:@"我知道了"
            otherButtonTitleList:nil];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:NSStringFromClass(self.class)];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)outOfUseful
{
    NSNumber *valid = [[NSUserDefaults standardUserDefaults] objectForKey:NSStringFromClass(self.class)];
    return valid != nil;
}

@end
