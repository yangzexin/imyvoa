//
//  TutorialManager.m
//  imyvoa
//
//  Created by yangzexin on 13-3-13.
//
//

#import "TutorialManager.h"
#import "Tutorial.h"

@interface TutorialManager ()

@property(nonatomic, retain)NSMutableDictionary *tutorialDictionary;

@end

@implementation TutorialManager

+ (id)defaultManager
{
    static id instance = nil;
    if(instance == nil){
        instance = [TutorialManager new];
    }
    return instance;
}

- (void)dealloc
{
    self.tutorialDictionary = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.tutorialDictionary = [NSMutableDictionary dictionary];
    
    return self;
}

- (void)setTutorialWithPageName:(NSString *)pageName tutorial:(id<Tutorial>)tutorial
{
    if(![tutorial outOfUseful]){
        [self.tutorialDictionary setObject:tutorial forKey:pageName];
    }
}

- (id<Tutorial>)tutorialForPageName:(NSString *)pageName
{
    return [self.tutorialDictionary objectForKey:pageName];
}

- (void)showTutorialWithPageName:(NSString *)pageName
{
    id<Tutorial> tutorial = [self tutorialForPageName:pageName];
    if(![tutorial outOfUseful]){
        [tutorial show];
    }
}

@end
