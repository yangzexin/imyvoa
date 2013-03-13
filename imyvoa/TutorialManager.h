//
//  TutorialManager.h
//  imyvoa
//
//  Created by yangzexin on 13-3-13.
//
//

#import <Foundation/Foundation.h>

@protocol Tutorial;

@interface TutorialManager : NSObject

+ (id)defaultManager;
- (void)setTutorialWithPageName:(NSString *)pageName tutorial:(id<Tutorial>)tutorial;
- (id<Tutorial>)tutorialForPageName:(NSString *)pageName;
- (void)showTutorialWithPageName:(NSString *)pageName;

@end
