//
//  CustomPickerView.m
//  GWRBar
//
//  Created by gewara on 11-12-2.
//  Copyright (c) 2011年 gewara. All rights reserved.
//

#import "CustomPickerView.h"

#define BLOCK_ALL
#define ANIMATION_DURATION 0.25f

@implementation CustomPickerView

@synthesize delegate = _delegate;
@synthesize bottomEdge;
@synthesize pickerView = _pickerView;
@synthesize indicatorView;

- (void)dealloc
{
    [_pickerView release];
    [toolbarTop release];
    [lblTitle release];
    [super dealloc];
}

- (void)appendSpaceToToolbarItems:(NSMutableArray *)array
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                          target:nil 
                                                                          action:nil];
    [array addObject:item];
    [item release]; item = nil;
}

- (void)initSubviews
{
#ifdef BLOCK_ALL
    self.hidden = YES;
#endif
    bottomEdge = 480;
    modal = NO;
    
    toolbarTop = [[UIToolbar alloc] init];
    toolbarTop.barStyle = UIBarStyleBlack;
    [self addSubview:toolbarTop];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    // 取消按钮
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" 
                                                                  style:UIBarButtonItemStyleBordered 
                                                                 target:self 
                                                                 action:@selector(onCancelBtnTapped)];
    [items addObject:btnCancel];
    [self appendSpaceToToolbarItems:items];
    // 标题
    lblTitle = [[UILabel alloc] init];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.font = [UIFont boldSystemFontOfSize:18.0f];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.textAlignment = UITextAlignmentCenter;
    UIBarButtonItem *btnLblTitle = [[UIBarButtonItem alloc] initWithCustomView:lblTitle];
    [items addObject:btnLblTitle];
    [self appendSpaceToToolbarItems:items];
    // 确认按钮
    UIBarButtonItem *btnApprove = [[UIBarButtonItem alloc] initWithTitle:@"确定" 
                                                                   style:UIBarButtonItemStyleDone 
                                                                  target:self 
                                                                  action:@selector(onApproveBtnTapped)];
    [items addObject:btnApprove];
    
    [toolbarTop setItems:items];
    
    [btnApprove release]; btnApprove = nil;
    [btnLblTitle release]; btnLblTitle = nil;
    [btnCancel release]; btnCancel = nil;
    [items release];
    
    _pickerView = [[UIPickerView alloc] init];
    _pickerView.showsSelectionIndicator = YES;
    [self addSubview:_pickerView];
    [self hide];
    
    indicatorView = [[UIActivityIndicatorView alloc] 
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self addSubview:indicatorView];
}

- (void)layoutSubviews
{
    toolbarTop.frame = CGRectMake(0, 0, self.frame.size.width, 44.0f);
    lblTitle.frame = CGRectMake(0, 0, 160.0f, 22.0f);
    _pickerView.frame = CGRectMake(0, 
                                   toolbarTop.frame.size.height, 
                                   self.frame.size.width, 
                                   self.frame.size.height - toolbarTop.frame.size.height);
    CGFloat indicatorWid = 44.0f;
    CGRect frame = CGRectMake((self.frame.size.width - indicatorWid) / 2, 
                              (self.frame.size.height - indicatorWid) / 2, 
                              indicatorWid, 
                              indicatorWid);
    indicatorView.frame = frame;
}

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self initSubviews];
    }
    return self;
}

- (id)init
{
    CGRect frame = [UIScreen mainScreen].bounds;
    if(self = [super initWithFrame:CGRectMake(0, 0, frame.size.width, 240.0f)]){
        [self initSubviews];
    }
    return self;
}

- (void)setPickerViewDelegate:(id<UIPickerViewDelegate>) delegate
{
    _pickerView.delegate = delegate;
}

- (void)setPickerViewDataSource:(id<UIPickerViewDataSource>) dataSource
{
    _pickerView.dataSource = dataSource;
}

- (id<UIPickerViewDelegate>)pickerViewDelegate
{
    return _pickerView.delegate;
}

- (id<UIPickerViewDataSource>)pickerViewDataSource
{
    return _pickerView.dataSource;
}

- (void)setTitle:(NSString *)title
{
    lblTitle.text = title;
}

- (void)hide
{
#ifdef BLOCK_ALL
    CGFloat height = self.superview.frame.size.height;
    if(![UIApplication sharedApplication].statusBarHidden){
        height += [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    self.frame = CGRectMake(0, height + 2, self.frame.size.width, self.frame.size.height);
#else
    self.frame = CGRectMake(0, bottomEdge + 2, self.frame.size.width, self.frame.size.height);
#endif
}

- (void)show
{
#ifdef BLOCK_ALL    
    CGFloat height = self.superview.frame.size.height;
    if(![UIApplication sharedApplication].statusBarHidden){
        height += [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    self.frame = CGRectMake(0, height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
#else
    self.frame = CGRectMake(0, bottomEdge - self.frame.size.height, self.frame.size.width, self.frame.size.height);
#endif
}

- (void)onHideAnimationDidStop
{
    if(modal){
        [self removeFromSuperview];
    }
}

- (void)hideWithAnimation
{
    // remove block view
    UIView *blockView = [self.superview viewWithTag:2277];
    [blockView removeFromSuperview];
    
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(onHideAnimationDidStop)];
    [self hide];
    [UIView commitAnimations];
}

- (void)onShowAnimationDidStoped
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(customPickerViewDidAppeared:)]){
        [self.delegate customPickerViewDidAppeared:self];
    }
    if(modal){
        [_pickerView reloadAllComponents];
    }
}

- (void)showWithAnimation
{
    if([self.delegate respondsToSelector:@selector(customPickerViewWillAppear:)]){
        [self.delegate customPickerViewWillAppear:self];
    }
    
#ifdef BLOCK_ALL
    if(self.superview){
        [self removeFromSuperview];
    }
    UIWindow *lastWindow = [[[UIApplication sharedApplication] windows] lastObject];
    [lastWindow addSubview:self];
    self.hidden = NO;
    [self hide];
#endif
    
    // add block view
    UIView *blockView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    blockView.backgroundColor = [UIColor blackColor];
    blockView.alpha = 0.20f;
    blockView.tag = 2277;
    NSArray *parentSubviews = [self.superview subviews];
    NSInteger targetIndex = 0;
    for(NSInteger i = 0; i < [parentSubviews count]; ++i){
        if([parentSubviews objectAtIndex:i] == self){
            targetIndex = i;
            break;
        }
    }
    [self.superview insertSubview:blockView atIndex:targetIndex];
    [blockView release]; blockView = nil;
    [self.superview bringSubviewToFront:self];
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(onShowAnimationDidStoped)];
    [self show];
    [UIView commitAnimations];
}

- (void)present
{
    modal = YES;
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [window addSubview:self];
    [self showWithAnimation];
}

- (NSInteger)selectedRowInComponent:(NSInteger)component
{
    return [_pickerView selectedRowInComponent:component];
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated
{
    [_pickerView selectRow:row inComponent:component animated:animated];
}

- (void)reloadComponent:(NSInteger)component
{
    [_pickerView reloadComponent:component];
}

- (void)setLoading:(BOOL)loading
{
    loading ? [indicatorView startAnimating] : [indicatorView stopAnimating];
    _pickerView.userInteractionEnabled = !loading;
}

#pragma mark - events
- (void)onCancelBtnTapped
{
    [self hideWithAnimation];
    if(self.delegate && [self.delegate respondsToSelector:@selector(customPickerViewDidCanceled:)]){
        [self.delegate customPickerViewDidCanceled:self];
    }
}

- (void)onApproveBtnTapped
{
    [self hideWithAnimation];
    if(self.delegate && [self.delegate respondsToSelector:@selector(customPickerViewDidApproved:)]){
        [self.delegate customPickerViewDidApproved:self];
    }
}

@end
