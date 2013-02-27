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

@interface BaseViewController ()

@property(nonatomic, retain)UILabel *titleLabel;
@property(nonatomic, copy)NSString *customTitle;
@property(nonatomic, retain)SVProviderPool *providerPool;

@end


@implementation BaseViewController

@synthesize titleLabel = _titleLabel;
@synthesize customTitle = _customTitle;

- (void)dealloc
{
    [_customTitle release];
    [_titleLabel release];
    [_providerPool release];

    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.title = NSLocalizedString(@"back", nil);
    _customTitle = @"";
    
    _providerPool = [[SVProviderPool alloc] init];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (UIView *)customTitleView
{
    return self.titleLabel;
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
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
