//
//  BaseViewController.m
//  VOA
//
//  Created by yangzexin on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SVProviderPool.h"
#import "Player.h"
#import "SVUIPrefersManager.h"

@interface BaseViewController ()

@property(nonatomic, retain)UILabel *titleLabel;
@property(nonatomic, copy)NSString *customTitle;
@property(nonatomic, retain)SVProviderPool *providerPool;
@property(nonatomic, retain)NSMutableArray *nonPrefersViewList;

@end


@implementation BaseViewController

@synthesize titleLabel = _titleLabel;
@synthesize customTitle = _customTitle;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_customTitle release];
    [_titleLabel release];
    [_providerPool release];
    self.nonPrefersViewList = nil;

    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.title = NSLocalizedString(@"back", nil);
    _customTitle = @"";
    
    _providerPool = [[SVProviderPool alloc] init];
    self.nonPrefersViewList = [NSMutableArray array];
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUIPerfers];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_UIPrefersManagerCurrentPrefersDidChange:)
                                                 name:kSVUIPrefersManagerCurrentPrefersDidChange
                                               object:nil];
}

- (void)loadView
{
    [super loadView];
    
    self.titleLabel = [[[UILabel alloc] init] autorelease];
    self.titleLabel.textAlignment = UITextAlignmentCenter;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    self.titleLabel.text = _customTitle;
    self.titleLabel.layer.shadowRadius = 0.5f;
    self.titleLabel.layer.shadowOpacity = 1.0f;
    self.titleLabel.layer.shadowOffset = CGSizeMake(0, -0.5f);
    self.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.frame = CGRectMake(0, 0, [_customTitle sizeWithFont:self.titleLabel.font].width, 
                                       self.titleLabel.font.lineHeight);
    self.navigationItem.titleView = self.titleLabel;
    
}

- (void)setCustomTitle:(NSString *)customTitle
{
    if(_customTitle != customTitle){
        [_customTitle release];
    }
    _customTitle = [customTitle copy];
    if(self.titleLabel){
        self.titleLabel.text = _customTitle;
        self.titleLabel.frame = CGRectMake(0, 0, 
                                           [_customTitle sizeWithFont:self.titleLabel.font].width, 
                                           self.titleLabel.font.lineHeight);
    }
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:NSLocalizedString(@"back", nil)];
    self.customTitle = title;
}

- (void)addProviderToPool:(id<SVProviderPoolable>)provider
{
    [_providerPool tryToReleaseProvider];
    [_providerPool addProvider:provider];
}

- (void)addViewToNonPrefersList:(UIView *)view
{
    [self.nonPrefersViewList addObject:view];
}

- (void)removeViewFromNonPrefersList:(UIView *)view
{
    [self.nonPrefersViewList removeObject:view];
}

- (UIView *)customTitleView
{
    return self.titleLabel;
}

- (void)updateUIPerfers
{
    NSMutableArray *views = [NSMutableArray arrayWithArray:self.view.subviews];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    if(navigationBar){
        [views addObject:navigationBar];
    }
    UIToolbar *toolbar = self.navigationController.toolbar;
    if(toolbar){
        [views addObject:toolbar];
    }
    UITabBar *tabBar = self.navigationController.tabBarController.tabBar;
    if(tabBar){
        [views addObject:tabBar];
    }
    for(UIView *view in self.nonPrefersViewList){
        [views removeObject:view];
    }
    [[SVUIPrefersManager defaultManager] configureViews:views];
}

- (void)_UIPrefersManagerCurrentPrefersDidChange:(NSNotification *)n
{
    [self updateUIPerfers];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown;
    }
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return YES;
    }
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
